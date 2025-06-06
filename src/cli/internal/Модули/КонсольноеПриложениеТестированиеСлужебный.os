#Использовать fs
#Использовать logos
#Использовать decorator
#Использовать fluent
#Использовать collectionos
#Использовать "../../../shared"

Функция СоздатьТочкуВхода(Детальки, МенеджерВременныхФайлов, Лог, ВыполняемаяКоманда) Экспорт

	Если Детальки.Получить("КаталогиТестов").Количество() = 0
		И Детальки.Получить("ФайлыТестов").Количество() = 0 Тогда
		Детальки.Получить("КаталогиТестов").Добавить("./tests");
	КонецЕсли;

	ФайлыТестовРазвернутые = ТестированиеСлужебный.РазвернутьСписокТестовыхНаборов(
		Детальки.Получить("КаталогиТестов"),
		Детальки.Получить("ФайлыТестов"),
		Детальки.Получить("ИскатьВПодкаталогах")
	);

	Импорты = Новый КартаСоответствие();

	ТекущийКаталог = ТекущийКаталог();

	Для каждого Тест Из ФайлыТестовРазвернутые Цикл

		ЧтениеТекста = Новый ЧтениеТекста(Тест.ПолноеИмя);

		УстановитьТекущийКаталог(Тест.Путь);

		Строка = ЧтениеТекста.ПрочитатьСтроку();

		Пока Строка <> Неопределено Цикл

			Если СтрНачинаетсяС(Строка, "#Использовать ") Тогда

				ПоПути = Ложь;

				Импорт = СтрЗаменить(Строка, "#Использовать ", "");
				Если СтрНайти(Импорт, """") > 0 Тогда
					Импорт = ФС.НормализоватьПуть(СтрЗаменить(Импорт, """", ""));
					ПоПути = Истина;
				КонецЕсли;

				Импорты.Вставить(Импорт, ПоПути);

			КонецЕсли;

			Строка = ЧтениеТекста.ПрочитатьСтроку();

		КонецЦикла;

		ЧтениеТекста.Закрыть();

		УстановитьТекущийКаталог(ТекущийКаталог);

	КонецЦикла;

	Лог.Отладка("Импорты считанные из тестов (Импорт=ПодключаетсяПоПути): %1", Импорты);

	КаталогПриложения = ФС.НормализоватьПуть(
		ОбъединитьПути(ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", ".."), "core")
	);

	ТекстСценария = Новый ПостроительДекоратора()
		.Импорт(Новый Импорт(КаталогПриложения).ТипПодключения(ТипыПодключенияБиблиотек.ПоПути))
		.ШагИнициализации(
			Новый ШагИнициализации(СтрШаблон("
				|
				|	Поделка = Новый Поделка(Новый СоветДругогоМастера()
				|		.ДополнительныйКаталогПоискаФайлаСоЗначениямиДеталек(""%2""));
				|	Поделка.ЗапуститьПриложение();
				|
				|	МенеджерТестирования = Поделка.НайтиЖелудь(""МенеджерТестирования"");
				|
				|	%1
				|",
				ВыполняемаяКоманда,
				МенеджерВременныхФайлов.БазовыйКаталог
			))
		)
		.ТекстСценария();

	Лог.Отладка("Текст сценария запуска тестирования: %1", ТекстСценария);

	ИмяВременногоФайла = МенеджерВременныхФайлов.НовоеИмяФайла("os");
	ЗаписьТекста = Новый ЗаписьТекста();
	ЗаписьТекста.Открыть(ИмяВременногоФайла);
	ЗаписьТекста.Записать(ТекстСценария);
	ЗаписьТекста.Закрыть();

	ТочкаВхода = Новый ПостроительДекоратора();

	Импорты.ЗаменитьВсе(
		"Импорт, ПоПути ->
		|	Результат = Новый Импорт("""" + Импорт + """");
		|	Если ПоПути Тогда
		|		Результат.ТипПодключения(ТипыПодключенияБиблиотек.ПоПути);
		|	КонецЕсли;
		|
		|	Возврат Результат;
		|"
	);

	Импорты.Значения()
		.ДляКаждого("Импорт -> ТочкаВхода.Импорт(Импорт)", Новый Структура("ТочкаВхода", ТочкаВхода));

	ТекстСценария = ТочкаВхода
		.ШагИнициализации(
			Новый ШагИнициализации(СтрШаблон("
				|
				|	// После импортов из тестов загружаем ядро и запускаем тесты
				|	ЗагрузитьСценарий(""%1"");
				|
				|",
				ИмяВременногоФайла
			))
		)
		.ТекстСценария();

	Лог.Отладка("Текст сценария точки входа для запуска тестирования: %1", ТекстСценария);

	ИмяВременногоФайла = МенеджерВременныхФайлов.НовоеИмяФайла("os");
	ЗаписьТекста = Новый ЗаписьТекста();
	ЗаписьТекста.Открыть(ИмяВременногоФайла);
	ЗаписьТекста.Записать(ТекстСценария);
	ЗаписьТекста.Закрыть();

	КонфигурационныйФайл(Детальки, МенеджерВременныхФайлов, Лог);
	ЗаписатьДетальки(Детальки, МенеджерВременныхФайлов);

	Возврат ИмяВременногоФайла;

КонецФункции

Функция ЗаписатьДетальки(Детальки, МенеджерВременныхФайлов)

	ЗначенияДеталек = Новый Соответствие;

	Для Каждого Деталька Из Детальки Цикл

		Если ТипЗнч(Деталька.Значение) = Тип("Массив")
			Или ТипЗнч(Деталька.Значение) = Тип("ФиксированныйМассив") Тогда

			Значение = СтрСоединить(Деталька.Значение, ",");

		Иначе
			Значение = Деталька.Значение;
		КонецЕсли;

		ЗначенияДеталек.Вставить(Деталька.Ключ, Значение);

	КонецЦикла;

	ПутьКФайлуДеталек = ОбъединитьПути(МенеджерВременныхФайлов.БазовыйКаталог, "autumn-properties.json");

	Настройки = Новый Соответствие(НастройкиЛогоса("core", "JSONРаскладкаСообщения"));
	Настройки.Вставить("OneUnit", ЗначенияДеталек);

	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.ОткрытьФайл(ПутьКФайлуДеталек);
	ЗаписатьJSON(ЗаписьJSON, Настройки);
	ЗаписьJSON.Закрыть();

	Возврат ПутьКФайлуДеталек;

КонецФункции

Функция КонфигурационныйФайл(Детальки, МенеджерВременныхФайлов, Лог)

	ПутиККонфигурационнымФайлам = Новый СписокМассив;
	ПутиККонфигурационнымФайлам.Добавить(ТекущийКаталог());

	Для каждого Путь Из Детальки.Получить("КаталогиТестов") Цикл
		ПутиККонфигурационнымФайлам.Добавить(Путь);
	КонецЦикла;

	Для каждого Путь Из Детальки.Получить("ФайлыТестов") Цикл
		ПутиККонфигурационнымФайлам.Добавить(Новый Файл(Путь).Путь);
	КонецЦикла;

	ДанныеКонфигурационногоФайла = ПутиККонфигурационнымФайлам.ПроцессорКоллекции()
		.Различные()
		.Обработать("Путь -> ОбъединитьПути(Путь, ""oscript.cfg"")")
		.Фильтровать("Путь -> ФС.ФайлСуществует(Путь)")
		.Обработать(Новый Действие(ЭтотОбъект, "ПрочитатьКонфигурационныйФайл"))
		.Развернуть("ДанныеФайла -> ДанныеФайла.КлючиИЗначения().ПроцессорКоллекции()")
		.Сократить(
			"Результат, Настройка ->
			|
			|	Результат.Слить(
			|		Настройка.Ключ,
			|		Настройка.Значение,
			|		""
			|		|Старое, Новое ->
			|		|	Если ТипЗнч(Старое) = Тип(""""МножествоСоответствие"""") Тогда
			|       |		Старое.ДобавитьВсе(Новое);
			|       |	КонецЕсли;
			|       |
			|		|	Возврат Старое;
			|		|""
			|	);
			|
			|	Возврат Результат;
			|",
			Новый КартаСоответствие()
		);

	ДанныеКонфигурационногоФайла.Слить(
		"lib.additional",
		Новый МножествоСоответствие(
			Множества.ИзЭлементов(ПолучитьЗначениеСистемнойНастройки("lib.system"))
		),
		"Старое, Новое -> Старое.ДобавитьВсе(Новое); Возврат Старое;"
	);

	ДанныеКонфигурационногоФайла.ВычислитьЕслиПрисутствует(
		"lib.additional",
		"Ключ, Значение -> Значение.Удалить(СистемныйКаталог); Возврат Значение;",
		Новый Структура("СистемныйКаталог", ДанныеКонфигурационногоФайла.Получить("lib.system").Иначе_(""))
	);

	Лог.Отладка("Данные конфигурационного файла: %1", ДанныеКонфигурационногоФайла);

	ПутьККонфигурационномуФайлу = ОбъединитьПути(МенеджерВременныхФайлов.БазовыйКаталог, "oscript.cfg");

	ЗаписьТекста = Новый ЗаписьТекста();
	ЗаписьТекста.Открыть(ПутьККонфигурационномуФайлу);

	ДанныеКонфигурационногоФайла.ДляКаждого(
		"Ключ, Значение -> ЗаписьТекста.ЗаписатьСтроку(
		|	Ключ + ""="" +
		|	?(ТипЗнч(Значение) = Тип(""МножествоСоответствие"") Или ТипЗнч(Значение) = Тип(""ФиксированноеМножество""),
		|		СтрСоединить(Значение.ВМассив(), "";""),
		|		Значение
		|	));",
		Новый Структура("ЗаписьТекста", ЗаписьТекста)
	);

	ЗаписьТекста.Закрыть();

	Возврат ПутьККонфигурационномуФайлу;

КонецФункции

Функция ПрочитатьКонфигурационныйФайл(Путь) Экспорт

	ТекущийКаталог = ТекущийКаталог();

	Результат = Новый КартаСоответствие();

	ЧтениеТекста = Новый ЧтениеТекста(Путь);

	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();

	Пока ПрочитаннаяСтрока <> Неопределено Цикл

		ПрочитаннаяСтрока = СтрРазделить(ПрочитаннаяСтрока, "=");

		Ключ = ПрочитаннаяСтрока[0];

		УстановитьТекущийКаталог(Новый Файл(Путь).Путь);

		Если СтрНачинаетсяС(Ключ, "lib.") Тогда

			Если СтрНачинаетсяС(Ключ, "lib.additional") Тогда

				Значение = ПроцессорыКоллекций.ИзКоллекции(СтрРазделить(ПрочитаннаяСтрока[1], ";", Ложь))
					.Фильтровать("Путь -> ФС.КаталогСуществует(Путь)")
					.Обработать("Путь -> ФС.НормализоватьПуть(Путь)")
					.Получить("МножествоСоответствие");

			Иначе
				Значение = ?(ФС.КаталогСуществует(ПрочитаннаяСтрока[1]), ФС.НормализоватьПуть(ПрочитаннаяСтрока[1]), "");
			КонецЕсли;

		Иначе
			Значение = ПрочитаннаяСтрока[1];
		КонецЕсли;

		УстановитьТекущийКаталог(ТекущийКаталог);

		Если ЗначениеЗаполнено(Значение) Тогда
			Результат.Вставить(Ключ, Значение);
		КонецЕсли;

		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();

	КонецЦикла;

	ЧтениеТекста.Закрыть();

	Возврат Результат;

КонецФункции

Функция РежимВыводаЛога(Режим) Экспорт

	Если НРег(Режим) = "none" Тогда
		Возврат РежимыВыводаЛога.Ничего;
	ИначеЕсли НРег(Режим) = "summary" Тогда
		Возврат РежимыВыводаЛога.Статистика;
	ИначеЕсли НРег(Режим) = "flat" Тогда
		Возврат РежимыВыводаЛога.ПлоскийСписок;
	ИначеЕсли НРег(Режим) = "tree" Тогда
		Возврат РежимыВыводаЛога.Дерево;
	Иначе
		ВызватьИсключение "Неизвестный режим вывода: " + Режим;
	КонецЕсли;

КонецФункции

Функция НастройкиЛогоса(Компонент, Раскладка) Экспорт

	Возврат Соответствия.ИзЭлементов(
		"logos.logger", Соответствия.ИзЭлементов(
			"oscript.lib.oneunit." + Компонент, Соответствия.ИзЭлементов(
				"level", "DEFAULT",
				"classlayout", Раскладка
			)
		)
	);

КонецФункции
