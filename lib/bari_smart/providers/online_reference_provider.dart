import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

class OnlineReferenceProvider implements BariProvider {
  final bool enabled;
  final bool showSources;
  final bool manualOnly;

  final Duration timeout;
  final Map<String, _CacheItem> _cache = {};

  OnlineReferenceProvider({
    required this.enabled,
    required this.showSources,
    required this.manualOnly,
    this.timeout = const Duration(seconds: 7),
  });

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    if (!enabled) {
      if (kDebugMode) {
        debugPrint('[BariOnline] disabled -> null');
      }
      return null;
    }
    if (manualOnly && !forceOnline) {
      if (kDebugMode) {
        debugPrint(
          '[BariOnline] manualOnly=true and forceOnline=false -> null',
        );
      }
      return null;
    }

    final q = _extractQuery(message);
    if (kDebugMode) {
      debugPrint(
        '[BariOnline] msg="$message" extractedQuery=${q == null ? "<null>" : '"$q"'} locale=${ctx.localeTag}',
      );
    }
    if (q == null) return null;
    if (!_isSafeTopic(q)) {
      if (kDebugMode) {
        debugPrint('[BariOnline] query not safe -> null (q="$q")');
      }
      return null;
    }

    final cacheKey = '${ctx.localeTag}|$q';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.time).inMinutes < 30) {
      return cached.value;
    }

    // 1) курсы валют (ECB)
    final rateRes = await _tryEcbRates(q).catchError((e) {
      if (kDebugMode) {
        debugPrint('[BariOnline] ECB error: $e');
      }
      return null;
    });
    if (rateRes != null) return _cacheIt(cacheKey, rateRes);

    // 2) инфляция по стране (World Bank)
    final inflRes = await _tryWorldBankInflation(q).catchError((e) {
      if (kDebugMode) {
        debugPrint('[BariOnline] WorldBank error: $e');
      }
      return null;
    });
    if (inflRes != null) return _cacheIt(cacheKey, inflRes);

    // 3) DuckDuckGo Instant Answer
    final ddgRes = await _tryDuckDuckGo(q, ctx.localeTag).catchError((e) {
      if (kDebugMode) {
        debugPrint('[BariOnline] DDG error: $e');
      }
      return null;
    });
    if (ddgRes != null) return _cacheIt(cacheKey, ddgRes);

    // 4) Wikipedia summary
    final wikiRes = await _tryWikipedia(q, ctx.localeTag).catchError((e) {
      if (kDebugMode) {
        debugPrint('[BariOnline] Wikipedia error: $e');
      }
      return null;
    });
    if (wikiRes != null) return _cacheIt(cacheKey, wikiRes);

    // 5) Wiktionary definition
    final wiktRes = await _tryWiktionary(q, ctx.localeTag).catchError((e) {
      if (kDebugMode) {
        debugPrint('[BariOnline] Wiktionary error: $e');
      }
      return null;
    });
    if (wiktRes != null) return _cacheIt(cacheKey, wiktRes);

    if (kDebugMode) {
      debugPrint('[BariOnline] no provider matched for q="$q"');
    }
    return null;
  }

  BariResponse _cacheIt(String k, BariResponse r) {
    _cache[k] = _CacheItem(DateTime.now(), r);
    return r;
  }

  // --------- Query & safety ---------

  String? _extractQuery(String msg) {
    final m = msg.trim().toLowerCase();

    String normalize(String s) {
      var x = s.toLowerCase().trim();
      // Убираем кавычки и лишнюю пунктуацию
      x = x.replaceAll(RegExp(r'^["«»\s]+'), '');
      x = x.replaceAll(RegExp(r'["«»\s]+$'), '');
      x = x.replaceAll(RegExp(r'[?!.:,;]+$'), '');
      x = x.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Обрезаем хвост после союзов/служебных слов, чтобы не отправлять "экономика и как..."
      final cut = RegExp(r'\s+(и|или|а|но|чтобы|как|почему|когда|где)\s+');
      final match = cut.firstMatch(x);
      if (match != null) {
        x = x.substring(0, match.start).trim();
      }

      // Если осталось много слов — берём первые 3 (обычно термина хватает)
      final parts = x.split(' ');
      if (parts.length > 3) {
        x = parts.take(3).join(' ').trim();
      }

      return x;
    }

    final patterns = [
      RegExp(r'что такое\s+(.+)', caseSensitive: false),
      RegExp(r'что значит\s+(.+)', caseSensitive: false),
      RegExp(r'объясни\s+(.+)', caseSensitive: false),
      RegExp(r'объясни,?\s+пожалуйста\s+(.+)', caseSensitive: false),
      RegExp(r'курс\s+(.+)', caseSensitive: false),
      RegExp(r'инфляц(ия|ии)\s+(.+)', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(m);
      if (match != null) {
        final q = normalize((match.group(match.groupCount) ?? '').trim());
        if (q.length >= 2) return q;
      }
    }

    if (m.length <= 60 && !m.contains('как дела') && !m.contains('привет')) {
      final q = normalize(m);
      if (q.length >= 2) return q;
    }
    return null;
  }

  bool _isSafeTopic(String q) {
    final t = q.toLowerCase();

    const deny = [
      'оруж',
      'наркот',
      'суиц',
      'порно',
      'секс',
      'взлом',
      'хак',
      'bomb',
      'kill',
      'диагноз',
      'лечение',
    ];
    for (final d in deny) {
      if (t.contains(d)) return false;
    }

    const allow = [
      'инфляц',
      'процент',
      'депозит',
      'кредит',
      'долг',
      'бюджет',
      'доход',
      'расход',
      'накоплен',
      'цель',
      'валют',
      'курс',
      'евро',
      'цена',
      'скидк',
      'подписк',
      'план',

      // Базовые экономические термины (часто спрашивают подростки)
      'экономик', 'рынок', 'спрос', 'предлож', 'налог', 'ввп', 'госдолг',
      'банк', 'центробанк', 'инвест', 'инвести', 'акци', 'облигац', 'капитал',
      'предприним', 'бизнес', 'конкур', 'монопол', 'кризис', 'рецесс',
      'зарплат', 'работ', 'безработ',
    ];

    if (allow.any((a) => t.contains(a))) {
      return true;
    }

    // Мягкий fallback для справочных запросов.
    // Например: "экономика", "капитализм", "деньги".
    // Без deny-совпадений безопаснее разрешить короткие однословные определения.
    final normalized = t
        .replaceAll(RegExp(r'[^a-zа-яё\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final isShort = normalized.length >= 2 && normalized.length <= 28;
    final isOneWord = !normalized.contains(' ');
    if (isShort && isOneWord) {
      return true;
    }

    return false;
  }

  // --------- ECB rates (EUR base) ---------

  Future<BariResponse?> _tryEcbRates(String q) async {
    final m = q.toUpperCase();
    if (!(m.contains('КУРС') ||
        m.contains('USD') ||
        m.contains('EUR') ||
        m.contains('CHF') ||
        m.contains('GBP'))) {
      return null;
    }

    // ECB daily XML
    final uri = Uri.parse(
      'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml',
    );
    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode != 200) return null;

    final body = resp.body;

    // очень простой парсинг (без XML пакета): вытащим пары currency/rate
    final rates = <String, double>{'EUR': 1.0};
    final regex = RegExp(r"currency='([A-Z]{3})'\s+rate='([0-9.]+)'");
    for (final match in regex.allMatches(body)) {
      rates[match.group(1)!] = double.parse(match.group(2)!);
    }
    if (rates.length < 5) return null;

    // извлечение пары из запроса
    final pair = RegExp(r'([A-Z]{3})\s*[/\s]\s*([A-Z]{3})').firstMatch(m);
    String a = 'EUR';
    String b = 'USD';
    if (pair != null) {
      a = pair.group(1)!;
      b = pair.group(2)!;
    } else if (m.contains('USD')) {
      a = 'EUR';
      b = 'USD';
    } else if (m.contains('CHF')) {
      a = 'EUR';
      b = 'CHF';
    }

    if (!rates.containsKey(a) || !rates.containsKey(b)) return null;

    // все курсы в XML: 1 EUR = rate CUR. Тогда:
    // CUR->EUR = 1 / rate(CUR)
    // A->B = (A->EUR) * (EUR->B)
    final double aToEur = (a == 'EUR') ? 1.0 : (1.0 / rates[a]!);
    final double eurToB = (b == 'EUR') ? 1.0 : rates[b]!;
    final aToB = aToEur * eurToB;

    final meaning =
        'Курс: 1 $a ≈ ${aToB.toStringAsFixed(4)} $b (справка, не для трейдинга 😄).';
    final advice = 'Хочешь — скажи сумму, я помогу прикинуть конвертацию.';

    final actions = <BariAction>[
      const BariAction(
        type: BariActionType.explainSimpler,
        label: 'Объясни проще',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: 'Калькуляторы',
        payload: 'calculators',
      ),
    ];

    final sourceUrl = uri.toString();
    if (showSources) {
      actions.insert(
        0,
        BariAction(
          type: BariActionType.showSource,
          label: 'Источник',
          payload: sourceUrl,
        ),
      );
    }

    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: actions.take(4).toList(),
      confidence: 0.78,
      sourceTitle: 'ECB eurofxref',
      sourceUrl: showSources ? sourceUrl : null,
    );
  }

  // --------- World Bank inflation (FP.CPI.TOTL.ZG) ---------

  Future<BariResponse?> _tryWorldBankInflation(String q) async {
    if (!q.toLowerCase().contains('инфляц') &&
        !q.toLowerCase().contains('inflation')) {
      return null;
    }

    final iso2 = _resolveCountryIso2(q);
    if (iso2 == null) return null;

    final uri = Uri.parse(
      'https://api.worldbank.org/v2/country/$iso2/indicator/FP.CPI.TOTL.ZG?format=json&per_page=10',
    );
    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode != 200) return null;

    final json = jsonDecode(resp.body);
    if (json is! List || json.length < 2) return null;

    final data = (json[1] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic>? latest;
    for (final row in data) {
      if (row['value'] != null) {
        latest = row;
        break;
      }
    }
    if (latest == null) return null;

    final year = (latest['date'] ?? '').toString();
    final value = (latest['value'] as num).toDouble();

    final meaning =
        'Инфляция в $iso2 за $year ≈ ${value.toStringAsFixed(2)}% (по данным World Bank).';
    final advice =
        'Если инфляция высокая — "то же самое" в магазине обычно становится дороже.';

    final actions = <BariAction>[
      const BariAction(
        type: BariActionType.explainSimpler,
        label: 'Объясни проще',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: 'Уроки',
        payload: 'lessons',
      ),
    ];

    final sourceUrl = uri.toString();
    if (showSources) {
      actions.insert(
        0,
        BariAction(
          type: BariActionType.showSource,
          label: 'Источник',
          payload: sourceUrl,
        ),
      );
    }

    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: actions.take(4).toList(),
      confidence: 0.76,
      sourceTitle: 'World Bank API',
      sourceUrl: showSources ? sourceUrl : null,
    );
  }

  String? _resolveCountryIso2(String q) {
    final s = q.toLowerCase();
    const map = {
      'австр': 'AT',
      'герман': 'DE',
      'немец': 'DE',
      'росс': 'RU',
      'украин': 'UA',
      'сша': 'US',
      'америк': 'US',
      'франц': 'FR',
      'итал': 'IT',
      'исп': 'ES',
      'польш': 'PL',
      'швейцар': 'CH',
      'austria': 'AT',
      'germany': 'DE',
      'switzerland': 'CH',
      'usa': 'US',
      'france': 'FR',
      'italy': 'IT',
      'spain': 'ES',
      'poland': 'PL',
      'russia': 'RU',
      'ukraine': 'UA',
    };

    for (final e in map.entries) {
      if (s.contains(e.key)) return e.value;
    }
    return null;
  }

  // --------- DuckDuckGo Instant Answer ---------

  Future<BariResponse?> _tryDuckDuckGo(String query, String localeTag) async {
    try {
      final uri = Uri.https('api.duckduckgo.com', '', {
        'q': query,
        'format': 'json',
        'no_html': '1',
        'skip_disambig': '1',
      });

      final resp = await http.get(uri).timeout(timeout);
      if (resp.statusCode != 200) return null;

      final j = jsonDecode(resp.body) as Map<String, dynamic>;

      // DuckDuckGo возвращает AbstractText или Definition
      final abstract = (j['AbstractText'] ?? '').toString().trim();
      final definition = (j['Definition'] ?? '').toString().trim();
      final answer = abstract.isNotEmpty ? abstract : definition;

      if (answer.isEmpty) return null;

      final short = _kidify(answer);
      final meaning = short;
      final advice = 'Хочешь — объясню на примере твоих денег в приложении.';

      final url = (j['AbstractURL'] ?? '').toString();
      final actions = <BariAction>[
        const BariAction(
          type: BariActionType.explainSimpler,
          label: 'Объясни проще',
        ),
        const BariAction(
          type: BariActionType.openScreen,
          label: 'Калькуляторы',
          payload: 'calculators',
        ),
      ];

      if (showSources && url.isNotEmpty) {
        actions.insert(
          0,
          BariAction(
            type: BariActionType.showSource,
            label: 'Источник',
            payload: url,
          ),
        );
      }

      return BariResponse(
        meaning: meaning,
        advice: advice,
        actions: actions.take(4).toList(),
        confidence: 0.72,
        sourceTitle: 'DuckDuckGo',
        sourceUrl: (showSources && url.isNotEmpty ? url : null),
      );
    } catch (e) {
      return null;
    }
  }

  // --------- Wikipedia summary ---------

  Future<BariResponse?> _tryWikipedia(String query, String localeTag) async {
    final lang = _lang(localeTag);
    final title = await _wikiTitle(lang, query);
    if (title == null) return null;

    final uri = Uri.https(
      '$lang.wikipedia.org',
      '/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
    );
    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode != 200) return null;

    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    final extract = (j['extract'] ?? '').toString().trim();
    if (extract.isEmpty) return null;

    final short = _kidify(extract);
    final meaning = '"$title" — это: $short';
    final advice = 'Хочешь — объясню на примере твоих денег в приложении.';

    final url = (j['content_urls']?['desktop']?['page'])?.toString();

    final actions = <BariAction>[
      const BariAction(
        type: BariActionType.explainSimpler,
        label: 'Объясни проще',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: 'Калькуляторы',
        payload: 'calculators',
      ),
    ];
    if (showSources && url != null) {
      actions.insert(
        0,
        BariAction(
          type: BariActionType.showSource,
          label: 'Источник',
          payload: url,
        ),
      );
    }

    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: actions.take(4).toList(),
      confidence: 0.74,
      sourceTitle: 'Wikipedia',
      sourceUrl: (showSources ? url : null),
    );
  }

  Future<String?> _wikiTitle(String lang, String query) async {
    final uri = Uri.https('$lang.wikipedia.org', '/w/api.php', {
      'action': 'opensearch',
      'search': query,
      'limit': '1',
      'namespace': '0',
      'format': 'json',
    });
    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode != 200) return null;
    final json = jsonDecode(resp.body);
    if (json is! List || json.length < 2) return null;
    final titles = (json[1] as List?)?.cast<String>() ?? const [];
    return titles.isEmpty ? null : titles.first;
  }

  // --------- Wiktionary definition ---------

  Future<BariResponse?> _tryWiktionary(String query, String localeTag) async {
    final lang = _lang(localeTag);
    final host = (lang == 'ru')
        ? 'ru.wiktionary.org'
        : (lang == 'de')
        ? 'de.wiktionary.org'
        : 'en.wiktionary.org';

    final uri = Uri.https(host, '/w/api.php', {
      'action': 'query',
      'prop': 'extracts',
      'exintro': '1',
      'explaintext': '1',
      'titles': query,
      'format': 'json',
      'redirects': '1',
    });

    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode != 200) return null;

    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    final pages = (j['query']?['pages'] as Map?)?.cast<String, dynamic>();
    if (pages == null || pages.isEmpty) return null;

    final page = pages.values.first as Map<String, dynamic>;
    final extract = (page['extract'] ?? '').toString().trim();
    if (extract.isEmpty) return null;

    final short = _kidify(extract);
    final meaning = 'Словарь говорит так: $short';
    final advice =
        'Если хочешь — скажи, где это встречается в жизни, и я помогу разобрать.';

    final actions = <BariAction>[
      const BariAction(
        type: BariActionType.explainSimpler,
        label: 'Объясни проще',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: 'Уроки',
        payload: 'lessons',
      ),
    ];

    final url = Uri.https(
      host,
      '/wiki/${Uri.encodeComponent(query)}',
    ).toString();
    if (showSources) {
      actions.insert(
        0,
        BariAction(
          type: BariActionType.showSource,
          label: 'Источник',
          payload: url,
        ),
      );
    }

    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: actions.take(4).toList(),
      sourceTitle: 'Wiktionary',
      sourceUrl: showSources ? url : null,
    );
  }

  String _lang(String localeTag) {
    final l = localeTag.split('_').first.toLowerCase();
    if (l == 'ru' || l == 'de' || l == 'en') return l;
    return 'en';
  }

  String _kidify(String s) {
    var x = s.replaceAll(RegExp(r'\([^)]*\)'), '');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = x.split(RegExp(r'(?<=[.!?])\s+'));
    final short = parts.take(2).join(' ').trim();
    if (short.length > 320) return '${short.substring(0, 320)}…';
    return short;
  }
}

class _CacheItem {
  final DateTime time;
  final BariResponse value;
  _CacheItem(this.time, this.value);
}
