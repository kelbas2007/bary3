import 'package:intl/intl.dart';
import '../models/template_config.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Улучшенные конфигурации шаблонов с параметрами и интеграцией
class EnhancedTemplates {
  static List<TemplateConfig> getTemplateConfigs() {
    return [
      // Шаблон цели
      TemplateConfig(
        templateId: 'goal',
        parameters: [
          TemplateParameter(
            id: 'goalName',
            label: (l10n) => 'Название цели',
            hint: (l10n) => 'На что копим?',
            type: ParameterType.text,
            required: true,
          ),
          TemplateParameter(
            id: 'amount',
            label: (l10n) => 'Сумма цели',
            hint: (l10n) => 'Сколько нужно накопить?',
            type: ParameterType.amount,
            required: true,
          ),
          TemplateParameter(
            id: 'deadline',
            label: (l10n) => 'Срок достижения',
            hint: (l10n) => 'Когда планируете достичь цели?',
            type: ParameterType.date,
            defaultValue: DateTime.now().add(const Duration(days: 30)),
          ),
          TemplateParameter(
            id: 'piggyBank',
            label: (l10n) => 'Копилка',
            hint: (l10n) => 'В какую копилку копим?',
            type: ParameterType.piggyBank,
          ),
          TemplateParameter(
            id: 'linkToEvent',
            label: (l10n) => 'Привязать к событию',
            type: ParameterType.checkbox,
            defaultValue: false,
          ),
          TemplateParameter(
            id: 'event',
            label: (l10n) => 'Событие',
            type: ParameterType.event,
          ),
        ],
        contentBuilder: (l10n, params) async {
          final goalName = params['goalName'] as String;
          final amount = params['amount'] as int;
          final deadline = params['deadline'] as DateTime?;
          final piggyBankId = params['piggyBank'] as String?;
          
          String piggyInfo = '';
          if (piggyBankId != null) {
            final banks = await StorageService.getPiggyBanks();
            final bank = banks.firstWhere(
              (b) => b.id == piggyBankId,
              orElse: () => banks.first,
            );
            piggyInfo = '\n🐷 Копилка: ${bank.name}\n   Текущий баланс: ${_formatMoney(bank.currentAmount)}\n   Осталось накопить: ${_formatMoney(amount - bank.currentAmount)}';
          }
          
          return '''🎯 Моя цель: $goalName

💰 Сумма: ${_formatMoney(amount)}
📅 Срок: ${deadline != null ? DateFormat('dd MMMM yyyy', 'ru').format(deadline) : 'Не указан'}$piggyInfo

✅ Шаги к достижению:
1. 
2. 
3. 

💪 Мотивация:
Почему это важно для меня?


📊 Прогресс:
''';
        },
        bariHintBuilder: (l10n, params, context) async {
          final amount = params['amount'] as int? ?? 0;
          final deadline = params['deadline'] as DateTime?;
          final piggyBankId = params['piggyBank'] as String?;
          
          if (piggyBankId != null) {
            final banks = await StorageService.getPiggyBanks();
            final bank = banks.firstWhere(
              (b) => b.id == piggyBankId,
              orElse: () => banks.first,
            );
            final remaining = amount - bank.currentAmount;
            final daysLeft = deadline?.difference(DateTime.now()).inDays;
            
            if (daysLeft != null && daysLeft > 0) {
              final daily = (remaining / daysLeft / 100).toStringAsFixed(0);
              return '💡 Чтобы достичь цели к сроку, нужно откладывать примерно $daily руб. в день. Это поможет вам дисциплинированно двигаться к цели!';
            }
          }
          
          return '💡 Разбейте большую цель на маленькие шаги - так будет проще двигаться вперед!';
        },
      ),
      
      // Шаблон планирования расходов
      TemplateConfig(
        templateId: 'expense_planning',
        parameters: [
          TemplateParameter(
            id: 'budget',
            label: (l10n) => 'Бюджет',
            hint: (l10n) => 'Сколько планируете потратить?',
            type: ParameterType.amount,
            required: true,
          ),
          TemplateParameter(
            id: 'date',
            label: (l10n) => 'Дата покупки',
            hint: (l10n) => 'Когда планируете покупку?',
            type: ParameterType.date,
            defaultValue: DateTime.now(),
          ),
          TemplateParameter(
            id: 'linkToEvent',
            label: (l10n) => 'Привязать к событию',
            type: ParameterType.checkbox,
            defaultValue: false,
          ),
          TemplateParameter(
            id: 'event',
            label: (l10n) => 'Событие',
            type: ParameterType.event,
          ),
        ],
        contentBuilder: (l10n, params) async {
          final budget = params['budget'] as int;
          final date = params['date'] as DateTime?;
          
          // Получаем похожие транзакции для подсказок
          final transactions = await StorageService.getTransactions();
          final similarExpenses = transactions
              .where((t) => 
                  t.type == TransactionType.expense &&
                  t.parentApproved &&
                  t.amount <= budget * 1.5 &&
                  t.amount >= budget * 0.5)
              .take(5)
              .toList();
          
          String suggestions = '';
          if (similarExpenses.isNotEmpty) {
            suggestions = '\n\n💡 Похожие покупки в истории:\n';
            for (var t in similarExpenses) {
              suggestions += '• ${t.note ?? "Покупка"} - ${_formatMoney(t.amount)}\n';
            }
          }
          
          return '''📝 Планирование расходов

💰 Бюджет: ${_formatMoney(budget)}
📅 Дата: ${date != null ? DateFormat('dd MMMM yyyy', 'ru').format(date) : 'Не указана'}

📋 Планируемые покупки:
• 
• 
• 

💡 Примечания:
$suggestions''';
        },
        bariHintBuilder: (l10n, params, context) async {
          final budget = params['budget'] as int? ?? 0;
          // context is BariContext from bari_context_adapter
          final balance = ((context as dynamic).currentBalance ?? 0) as int;
          
          if (balance < budget) {
            return '⚠️ Внимание! У вас недостаточно средств для этой покупки. Нужно накопить еще ${_formatMoney(budget - balance)}.';
          } else if (balance < (budget * 1.5).round()) {
            return '💡 После этой покупки у вас останется немного денег. Убедитесь, что это действительно необходимо!';
          }
          
          return '✅ У вас достаточно средств для этой покупки. Не забудьте сравнить цены в разных магазинах!';
        },
      ),
      
      // Шаблон списка покупок
      TemplateConfig(
        templateId: 'shopping_list',
        parameters: [
          TemplateParameter(
            id: 'date',
            label: (l10n) => 'Дата похода в магазин',
            hint: (l10n) => 'Когда планируете покупки?',
            type: ParameterType.date,
            defaultValue: DateTime.now(),
          ),
          TemplateParameter(
            id: 'budget',
            label: (l10n) => 'Бюджет',
            hint: (l10n) => 'Сколько планируете потратить?',
            type: ParameterType.amount,
          ),
        ],
        contentBuilder: (l10n, params) async {
          final date = params['date'] as DateTime?;
          final budget = params['budget'] as int?;
          
          return '''🛒 Список покупок

📅 Дата: ${date != null ? DateFormat('dd MMMM yyyy', 'ru').format(date) : 'Не указана'}
${budget != null ? '💰 Бюджет: ${_formatMoney(budget)}\n' : ''}
✅ Нужно купить:
☐ 
☐ 
☐ 
☐ 
☐ 

💡 Примечания:
''';
        },
        bariHintBuilder: (l10n, params, context) async {
          final budget = params['budget'] as int?;
          if (budget != null) {
            return '💡 Составьте список заранее и придерживайтесь бюджета - это поможет избежать импульсивных покупок!';
          }
          return '💡 Составление списка покупок помогает не забыть нужное и избежать лишних трат!';
        },
      ),
      
      // Шаблон размышлений
      TemplateConfig(
        templateId: 'reflection',
        parameters: [
          TemplateParameter(
            id: 'date',
            label: (l10n) => 'Дата',
            hint: (l10n) => 'О каком дне размышляете?',
            type: ParameterType.date,
            defaultValue: DateTime.now(),
          ),
        ],
        contentBuilder: (l10n, params) async {
          final date = params['date'] as DateTime?;
          final profile = await StorageService.getPlayerProfile();
          
          return '''🤔 Размышления

📅 Дата: ${date != null ? DateFormat('dd MMMM yyyy', 'ru').format(date) : 'Сегодня'}

💭 О чем думаю:
_____


✨ Что понял сегодня:
• 
• 

🎯 Что хочу изменить:
• 

💪 Мои планы на завтра:
• 

📊 Мой прогресс:
• Серия дней активности: ${profile.streakDays}
• Самоконтроль: ${profile.selfControlScore}/100
''';
        },
        bariHintBuilder: (l10n, params, context) async {
          return '💡 Рефлексия - это важный навык! Записывайте свои мысли регулярно, чтобы лучше понимать себя и свои финансовые решения.';
        },
      ),
      
      // Шаблон благодарности
      TemplateConfig(
        templateId: 'gratitude',
        parameters: [
          TemplateParameter(
            id: 'date',
            label: (l10n) => 'Дата',
            hint: (l10n) => 'За какой день благодарность?',
            type: ParameterType.date,
            defaultValue: DateTime.now(),
          ),
        ],
        contentBuilder: (l10n, params) async {
          final date = params['date'] as DateTime?;
          
          return '''🙏 Благодарность

📅 Дата: ${date != null ? DateFormat('dd MMMM yyyy', 'ru').format(date) : 'Сегодня'}

💖 За что я благодарен сегодня:
1. 
2. 
3. 

😊 Что хорошего произошло:
• 
• 

💝 Что меня радует:
• 

🌟 За что я благодарен в финансовом плане:
• 
''';
        },
        bariHintBuilder: (l10n, params, context) async {
          return '💡 Практика благодарности помогает ценить то, что у нас есть, и делает нас счастливее!';
        },
      ),
    ];
  }
  
  static String _formatMoney(int cents) {
    final rubles = cents / 100;
    if (rubles == rubles.toInt()) {
      return '${rubles.toInt()} руб.';
    }
    return '${rubles.toStringAsFixed(2)} руб.';
  }
}
