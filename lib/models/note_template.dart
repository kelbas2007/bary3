import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Шаблон заметки для быстрого создания
class NoteTemplate {
  final String id;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) description;
  final IconData icon;
  final Color color;
  final String Function(AppLocalizations l10n) contentBuilder;

  const NoteTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.contentBuilder,
  });
}

/// Коллекция шаблонов заметок
class NoteTemplates {
  static List<NoteTemplate> getTemplates() {
    return [
      // Шаблон отчета для родителей
      NoteTemplate(
        id: 'parent_report',
        title: (l10n) => l10n.notes_templateParentReport,
        description: (l10n) => l10n.notes_templateParentReportDesc,
        icon: Icons.assessment,
        color: Colors.teal,
        contentBuilder: (l10n) => '''📊 Отчет для родителей

📅 Период: _____
👤 Ребенок: _____

💰 ФИНАНСОВАЯ СВОДКА:
• Доходы: _____ руб.
• Расходы: _____ руб.
• Баланс: _____ руб.

📈 АКТИВНОСТЬ:
• Завершено планов: _____
• Выполнено задач: _____
• Пройдено уроков: _____

💡 ВЫВОДЫ И РЕКОМЕНДАЦИИ:
''',
      ),
      NoteTemplate(
        id: 'expense_planning',
        title: (l10n) => l10n.notes_templateExpense,
        description: (l10n) => l10n.notes_templateExpenseDesc,
        icon: Icons.shopping_cart,
        color: Colors.orange,
        contentBuilder: (l10n) => '''📝 Планирование расходов

💰 Бюджет: _____ руб.
📅 Дата: _____

📋 Планируемые покупки:
• 
• 
• 

💡 Примечания:
''',
      ),
      NoteTemplate(
        id: 'goal',
        title: (l10n) => l10n.notes_templateGoal,
        description: (l10n) => l10n.notes_templateGoalDesc,
        icon: Icons.flag,
        color: Colors.green,
        contentBuilder: (l10n) => '''🎯 Моя цель

💭 Описание цели:
_____

💰 Сумма: _____ руб.
📅 Срок: _____

✅ Шаги к достижению:
1. 
2. 
3. 

💪 Мотивация:
''',
      ),
      NoteTemplate(
        id: 'idea',
        title: (l10n) => l10n.notes_templateIdea,
        description: (l10n) => l10n.notes_templateIdeaDesc,
        icon: Icons.lightbulb,
        color: Colors.yellow,
        contentBuilder: (l10n) => '''💡 Идея

📝 Описание:
_____

🎯 Как это поможет:
• 
• 

💭 Дополнительные мысли:
''',
      ),
      NoteTemplate(
        id: 'meeting',
        title: (l10n) => l10n.notes_templateMeeting,
        description: (l10n) => l10n.notes_templateMeetingDesc,
        icon: Icons.event,
        color: Colors.blue,
        contentBuilder: (l10n) => '''📅 Встреча

👥 Участники:
• 
• 

📋 Повестка:
1. 
2. 
3. 

✅ Решения:
• 

📝 Действия:
• 
• 
''',
      ),
      NoteTemplate(
        id: 'learning',
        title: (l10n) => l10n.notes_templateLearning,
        description: (l10n) => l10n.notes_templateLearningDesc,
        icon: Icons.school,
        color: Colors.purple,
        contentBuilder: (l10n) => '''📚 Урок

📖 Тема: _____

💡 Что узнал:
• 
• 
• 

❓ Вопросы:
• 

📝 Практика:
''',
      ),
      // Дополнительные шаблоны
      NoteTemplate(
        id: 'shopping_list',
        title: (l10n) => l10n.notes_templateShoppingList,
        description: (l10n) => l10n.notes_templateShoppingListDesc,
        icon: Icons.shopping_bag,
        color: Colors.pink,
        contentBuilder: (l10n) => '''🛒 Список покупок

📅 Дата: _____

✅ Нужно купить:
☐ 
☐ 
☐ 
☐ 
☐ 

💰 Бюджет: _____ руб.

💡 Примечания:
''',
      ),
      NoteTemplate(
        id: 'reflection',
        title: (l10n) => l10n.notes_templateReflection,
        description: (l10n) => l10n.notes_templateReflectionDesc,
        icon: Icons.psychology,
        color: Colors.indigo,
        contentBuilder: (l10n) => '''🤔 Размышления

📅 Дата: _____

💭 О чем думаю:
_____

✨ Что понял:
• 
• 

🎯 Что хочу изменить:
• 

💪 Мои планы:
''',
      ),
      NoteTemplate(
        id: 'gratitude',
        title: (l10n) => l10n.notes_templateGratitude,
        description: (l10n) => l10n.notes_templateGratitudeDesc,
        icon: Icons.favorite,
        color: Colors.red,
        contentBuilder: (l10n) => '''❤️ Благодарность

📅 Дата: _____

🙏 За что я благодарен сегодня:
1. 
2. 
3. 

💝 Что хорошего произошло:
• 
• 

😊 Что меня радует:
''',
      ),
    ];
  }
}
