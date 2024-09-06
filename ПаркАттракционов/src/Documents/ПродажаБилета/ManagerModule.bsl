// @strict-types


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Процедура заполняет табличный документ для печати
// 
// Параметры:
//  ТабДок - ТабличныйДокумент - табличный документ для заполнения и печати
//  Ссылка - Произвольный - содержит ссылку на объект, для которого вызвана команда печати
//  
//  Структура:
//  *Дата - Строка
//
Процедура Билет(ТабДок, Ссылка) Экспорт
	
	Макет = ПолучитьМакет("Билет");
	
	Выборка = ВыборкаПродажаБилета(Ссылка);

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	Шапка = Макет.ПолучитьОбласть("Шапка");
	
	ТабДок.Очистить();

	ВставлятьРазделительСтраниц = Ложь;
	Пока Выборка.Следующий() Цикл
		Если ВставлятьРазделительСтраниц Тогда
			ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		ПараметрыОбласти = Новый Структура; // Инициализация без указания начального типа
		ПараметрыОбласти.Вставить("Дата", Формат(Выборка.Дата, "ДЛФ=D;"));
		ПараметрыОбласти.Вставить("Номер", УдалитьЛидирующиеНули(Выборка.Номер));
		
		ОбластьЗаголовок.Параметры.Заполнить(ПараметрыОбласти);
		ТабДок.Вывести(ОбластьЗаголовок);
		
		Шапка.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Шапка, Выборка.Уровень());	
		
		ВставлятьРазделительСтраниц = Истина;
	КонецЦикла;
	
КонецПроцедуры

// Обработчик перехода на новую версию
// Переносит значения реквизитов в новую табличную часть
//
Процедура ПеренестиНоменклатуруВТабличнуюЧасть() Экспорт

	Выборка = ВыборкаПродажаБилетаСсылка();
	
	Пока Выборка.Следующий() Цикл
		// Проводим перенос данных в обновленную форму
		ДокОбъект = Выборка.Ссылка.ПолучитьОбъект();
		Строка = ДокОбъект.ПозицииПродажи.Добавить();
		Строка.Номенклатура = ДокОбъект.УдалитьНоменклатура;
		Строка.Цена = ДокОбъект.УдалитьЦена;
		Строка.Количество = 1;
		Строка.Сумма = Строка.Цена;
		// Записываем данные без перепроведения
		ДокОбъект.ОбменДанными.Загрузка = Истина;
		ДокОбъект.Записать();

	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

// Код процедур и функций

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Удалить лидирующие нули.
// 
// Параметры:
//  Номер - Строка - Номер
// 
// Возвращаемое значение:
//  Строка - Удалить лидирующие нули
Функция УдалитьЛидирующиеНули(Номер)
	
	Результат = Номер;
	Пока СтрНачинаетсяС(Результат, "0") Цикл
		Результат = Сред(Результат, 2);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Выборка продажа билета.
// 
// Параметры:
//  Ссылка - Произвольный - Ссылка:
// * Дата - Строка -
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Выборка продажа билета:
//  *Номер - Строка
//  *Дата - Дата
//  *Номенклатура - СправочникСсылка.Номенклатура
//  *КоличествоПосещений - Число
//  *СуммаДокумента - Число
//
Функция ВыборкаПродажаБилета(Ссылка)

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ПродажаБилета.Номер,
		|	ПродажаБилета.Дата,
		|	ПродажаБилета.Номенклатура,
		|	ПродажаБилета.Номенклатура.КоличествоПосещений КАК КоличествоПосещений,
		|	ПродажаБилета.СуммаДокумента
		|ИЗ
		|	Документ.ПродажаБилета КАК ПродажаБилета
		|ГДЕ
		|	ПродажаБилета.Ссылка В (&Ссылка)";
		
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка;
	
КонецФункции

// Выборка продажа билета ссылка.
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Выборка продажа билета ссылка:
//  *Ссылка - ДокументСсылка.ПродажаБилета
//
Функция ВыборкаПродажаБилетаСсылка()

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ПродажаБилета.Ссылка
		|ИЗ
		|	Документ.ПродажаБилета КАК ПродажаБилета
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПродажаБилета.ПозицииПродажи КАК ПродажаБилетаПозицииПродажи
		|		ПО ПродажаБилетаПозицииПродажи.Ссылка = ПродажаБилета.Ссылка
		|		И ПродажаБилета.ПозицииПродажи.НомерСтроки = 1
		|ГДЕ
		|	ПродажаБилета.УдалитьНоменклатура <> ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
		|	И ПродажаБилетаПозицииПродажи.Ссылка ЕСТЬ NULL";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка;
	
КонецФункции

#КонецОбласти

#КонецЕсли
