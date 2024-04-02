//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2024 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

#Область СлужебныйПрограммныйИнтерфейс

Функция ПараметрыГенерацииОтчета() Экспорт
	
	Параметры = ЮТФабрикаСлужебный.ПараметрыГенератораОтчета();
	
	ОписаниеФормата = ЮТФабрикаСлужебный.ОписаниеФорматаОтчета("jUnit", "JUnit");
	ОписаниеФормата.ИмяФайлаПоУмолчанию = "junit.xml";
	ОписаниеФормата.ФильтрВыбораФайла = "jUnit(*.xml)|*.xml";
	Параметры.Форматы.Вставить(ОписаниеФормата.Идентификатор, ОписаниеФормата);
	
	Возврат Параметры;
	
КонецФункции

// Формирует отчет в формате jUnit
// 
// Параметры:
//  РезультатВыполнения - Массив из см. ЮТФабрикаСлужебный.ОписаниеИсполняемогоТестовогоМодуля
//  Формат - см. ЮТФабрикаСлужебный.ОписаниеФорматаОтчета
//
// Возвращаемое значение:
//  ДвоичныеДанные - Данные отчета
Функция ДанныеОтчета(Знач РезультатВыполнения, Формат) Экспорт
	
	Возврат СформироватьОтчетОТестировании(РезультатВыполнения);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// СформироватьОтчетОТестировании
//  Формирует отчет (xml-файл) и возвращает его в виде двоичных данных
//  
// Параметры:
// 	РезультатТестирования - Массив из см. ЮТФабрикаСлужебный.ОписаниеИсполняемогоТестовогоМодуля
// Возвращаемое значение:
// 	ДвоичныеДанные - полученный отчет
Функция СформироватьОтчетОТестировании(РезультатТестирования)
	
	Поток = Новый ПотокВПамяти();
	ЗаписьXML = Новый ЗаписьXML;
	
	ЗаписьXML.ОткрытьПоток(Поток, "UTF-8", Ложь);
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuites");
	
	Номер = 0;
	
	Для Каждого Модуль Из РезультатТестирования Цикл
		
		Для Каждого Набор Из Модуль.НаборыТестов Цикл
			
			ЗаписатьНабор(ЗаписьXML, Набор, Номер);
			Номер = Номер + 1;
			
		КонецЦикла;
		
	КонецЦикла;
	
	ЗаписатьСвойства(ЗаписьXML, Новый Структура("executor, reportDate", "BIA YAxUnit", ТекущаяДатаСеанса()));
	
	ЗаписьXML.ЗаписатьКонецЭлемента();
	ЗаписьXML.Закрыть();
	
	Возврат Поток.ЗакрытьИПолучитьДвоичныеДанные();
	
КонецФункции

// ЗаписатьРезультатТеста
// 
// Параметры:
//  ЗаписьXML - ЗаписьXML - Запись XML
//  РезультатТеста - Структура - Результат теста
Процедура ЗаписатьТест(ЗаписьXML, РезультатТеста)
	
	Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testcase");
	ЗаписьXML.ЗаписатьАтрибут("name", РезультатТеста.Имя);
	ЗаписьXML.ЗаписатьАтрибут("classname", РезультатТеста.ПолноеИмяМетода);
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(ЮТОбщий.ПродолжительностьВСекундах(РезультатТеста.Длительность)));
	ЗаписьXML.ЗаписатьАтрибут("context", РезультатТеста.Режим);
	
	Для Каждого ОписаниеОшибки Из РезультатТеста.Ошибки Цикл
		
		Статус = ЮТРегистрацияОшибокСлужебный.СтатусОшибки(ОписаниеОшибки.ТипОшибки);
		
		ИмяУзла = Неопределено;
		ЗаписатьЗначения = Ложь;
		ЗаписатьСтек = Ложь;
		Если Статус = Статусы.Ошибка Тогда
			ИмяУзла = "failure";
			ЗаписатьЗначения = Истина;
			ЗаписатьСтек = Истина;
		ИначеЕсли Статус = Статусы.Пропущен Тогда
			ИмяУзла = "skipped";
			ЗаписатьСтек = Истина;
		ИначеЕсли Статус = Статусы.Ожидание Тогда
			ИмяУзла = "skipped";
			ЗаписатьСтек = Истина;
		ИначеЕсли Статус <> Статусы.Успешно Тогда
			ИмяУзла = "error";
			ЗаписатьСтек = Истина;
		КонецЕсли;
		
		Сообщение = СообщениеОбОшибке(ОписаниеОшибки);
		ЗаписьXML.ЗаписатьНачалоЭлемента(ИмяУзла);
		ЗаписьXML.ЗаписатьАтрибут("message", Сообщение);
		
		Если ЗначениеЗаполнено(ОписаниеОшибки.ТипОшибки) Тогда
			ЗаписьXML.ЗаписатьАтрибут("type", XMLСтрока(ОписаниеОшибки.ТипОшибки));
		КонецЕсли;
		
		Если ЗаписатьЗначения Тогда
			Если ОписаниеОшибки.ОжидаемоеЗначение <> Неопределено Тогда
				ЗаписьXML.ЗаписатьНачалоЭлемента("expected");
				ЗаписьXML.ЗаписатьТекст(ЗначениеВСтрокуjUnit(ОписаниеОшибки.ОжидаемоеЗначение));
				ЗаписьXML.ЗаписатьКонецЭлемента();
			КонецЕсли;
			
			Если ОписаниеОшибки.ПроверяемоеЗначение <> Неопределено Тогда
				ЗаписьXML.ЗаписатьНачалоЭлемента("actual");
				ЗаписьXML.ЗаписатьТекст(ЗначениеВСтрокуjUnit(ОписаниеОшибки.ПроверяемоеЗначение));
				ЗаписьXML.ЗаписатьКонецЭлемента();
			КонецЕсли;
		КонецЕсли;
		
		Если ЗаписатьСтек И ОписаниеОшибки.Стек <> Неопределено Тогда
			ЗаписьXML.ЗаписатьТекст(ОписаниеОшибки.Стек);
		КонецЕсли;
		
		ЗаписьXML.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
	Если РезультатТеста.Ошибки.Количество() = 0 И РезультатТеста.Статус <> Статусы.Успешно Тогда
		
		Если РезультатТеста.Статус = Статусы.Ожидание Тогда
			
			ЗаписьXML.ЗаписатьНачалоЭлемента("skipped");
			ЗаписьXML.ЗаписатьАтрибут("message", "Тест не был вызван");
			ЗаписьXML.ЗаписатьКонецЭлемента();
			
		Иначе
			
			ЗаписьXML.ЗаписатьНачалоЭлемента("error");
			ЗаписьXML.ЗаписатьАтрибут("message", "Тест не успешен, но нет сообщений об ошибках");
			ЗаписьXML.ЗаписатьКонецЭлемента();
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента();
	
КонецПроцедуры

Процедура ЗаписатьОшибку(ЗаписьXML, ОписаниеОшибки)
	Сообщение = СообщениеОбОшибке(ОписаниеОшибки);
	ЗаписьXML.ЗаписатьНачалоЭлемента("error");
	Если Сообщение <> Неопределено Тогда
		ЗаписьXML.ЗаписатьАтрибут("message", Сообщение);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеОшибки.ТипОшибки) Тогда
		ЗаписьXML.ЗаписатьАтрибут("type", XMLСтрока(ОписаниеОшибки.ТипОшибки));
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеОшибки.Стек) Тогда
		ЗаписьXML.ЗаписатьТекст(ОписаниеОшибки.Стек);
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента();
КонецПроцедуры

Процедура ЗаписатьНабор(ЗаписьXML, Набор, Номер)
	
	КоличествоТестов = 0;
	КоличествоПропущенных = 0;
	КоличествоУпавших = 0;
	КоличествоСломанных = 0;
	
	Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	
	Для Каждого РезультатТеста Из Набор.Тесты Цикл
		
		КоличествоТестов = КоличествоТестов + 1;
		
		Если РезультатТеста.Статус = Статусы.Ошибка Тогда
			КоличествоУпавших = КоличествоУпавших + 1;
		ИначеЕсли РезультатТеста.Статус = Статусы.Пропущен ИЛИ РезультатТеста.Статус = Статусы.Ожидание Тогда
			КоличествоПропущенных = КоличествоПропущенных + 1;
		ИначеЕсли РезультатТеста.Статус <> Статусы.Успешно Тогда
			КоличествоСломанных = КоличествоСломанных + 1;
		КонецЕсли;
		
	КонецЦикла;
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");
	ЗаписьXML.ЗаписатьАтрибут("id", XMLСтрока(Номер));
	ЗаписьXML.ЗаписатьАтрибут("name", СтрШаблон("%1 [%2]", Набор.Представление, Набор.Режим));
	ЗаписьXML.ЗаписатьАтрибут("tests", XMLСтрока(КоличествоТестов));
	ЗаписьXML.ЗаписатьАтрибут("errors", XMLСтрока(КоличествоСломанных));
	ЗаписьXML.ЗаписатьАтрибут("skipped", XMLСтрока(КоличествоПропущенных));
	ЗаписьXML.ЗаписатьАтрибут("failures", XMLСтрока(КоличествоУпавших));
	ЗаписьXML.ЗаписатьАтрибут("timestamp", XMLСтрока(ЮТОбщий.МестноеВремяПоВременнойМетке(Набор.ДатаСтарта)));
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(ЮТОбщий.ПродолжительностьВСекундах(Набор.Длительность)));
	ЗаписьXML.ЗаписатьАтрибут("package", Набор.МетаданныеМодуля.Расширение);
	ЗаписьXML.ЗаписатьАтрибут("context", Набор.Режим);
	
	Для Каждого ОписаниеОшибки Из Набор.Ошибки Цикл
		ЗаписатьОшибку(ЗаписьXML, ОписаниеОшибки);
	КонецЦикла;
		
	Для Каждого РезультатТеста Из Набор.Тесты Цикл
		
		ЗаписатьТест(ЗаписьXML, РезультатТеста);
		
	КонецЦикла;
	
	ЗаписатьСвойства(ЗаписьXML, Новый Структура("context", Набор.Режим));
	ЗаписьXML.ЗаписатьКонецЭлемента(); // testsuite
	
КонецПроцедуры

Функция ЗначениеВСтрокуjUnit(Знач Значение)
	
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипЗначения = Тип("Строка") Тогда
	
		Возврат XMLСтрока(Значение);
	
	ИначеЕсли ТипЗначения = Тип("Массив") Тогда
	
		Возврат ЗначениеВСтрокуМассивjUnit(Значение);
	
	ИначеЕсли ТипЗначения = Тип("Структура") Или ТипЗначения = Тип("Соответствие") Или ТипЗначения = Тип("СписокЗначений") Тогда
		
		Возврат ЗначениеВСтрокуПростаяКоллекцияjUnit(Значение);
		
	ИначеЕсли ТипЗначения = Тип("Тип") Или ТипЗначения = Тип("СтандартныйПериод") Тогда
		
		Возврат Строка(Значение);
		
	Иначе
		
		Попытка
			
			Возврат XMLСтрока(Значение);
			
		Исключение
			
			Возврат Строка(Значение);
			
		КонецПопытки;
		
	КонецЕсли;
	
КонецФункции

Функция ЗначениеВСтрокуМассивjUnit(Коллекция)
	
	Стр = "";
	
	Для Ккк = 0 По Коллекция.Количество() - 1 Цикл
		
		Стр = Стр + ЗначениеВСтрокуjUnit(Коллекция[Ккк]);
		
		Если Ккк < Коллекция.Количество() - 1 Тогда
			
			Стр = Стр + Символы.ПС;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Стр;
	
КонецФункции

Функция ЗначениеВСтрокуПростаяКоллекцияjUnit(Коллекция)
	
	Стр = "|";
	
	Для Каждого Элем Из Коллекция Цикл
		
		Стр = " " + Стр + Элем.Значение + " |";
		
	КонецЦикла;
	
	Возврат Стр;
	
КонецФункции

Функция СообщениеОбОшибке(ОписаниеОшибки)
	
	Если ТипЗнч(ОписаниеОшибки) = Тип("Структура") Тогда
		Сообщение = ОписаниеОшибки.Сообщение;
	ИначеЕсли ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		Сообщение = Строка(ОписаниеОшибки);
	Иначе
		Сообщение = Неопределено;
	КонецЕсли;
	
	Возврат Сообщение;
	
КонецФункции

Процедура ЗаписатьСвойства(ЗаписьXML, Свойства)
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("properties");
	
	Для Каждого Свойство Из Свойства Цикл
		ЗаписьXML.ЗаписатьНачалоЭлемента("property");
		ЗаписьXML.ЗаписатьАтрибут("name", Свойство.Ключ);
		ЗаписьXML.ЗаписатьАтрибут("value", ЗначениеВСтрокуjUnit(Свойство.Значение));
		ЗаписьXML.ЗаписатьКонецЭлемента(); // property
	КонецЦикла;
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); // properties
	
КонецПроцедуры

#КонецОбласти
