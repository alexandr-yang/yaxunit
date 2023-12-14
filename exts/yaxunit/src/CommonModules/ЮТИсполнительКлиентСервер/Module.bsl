//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
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

// Выполняет тесты группы наборов, соответствующих одному режиму выполнения (клиент/сервер) 
// Параметры:
//  Наборы - Массив из см. ЮТФабрика.ОписаниеИсполняемогоНабораТестов - Наборы тестов модуля
//  ТестовыйМодуль - см. ЮТФабрика.ОписаниеИсполняемогоТестовогоМодуля
// 
// Возвращаемое значение:
//  Массив из см. ЮТФабрика.ОписаниеИсполняемогоНабораТестов - Результат прогона наборов тестов с заполненной информацией о выполнении
Функция ВыполнитьГруппуНаборовТестов(Наборы, ТестовыйМодуль) Экспорт
	
	Если Наборы.Количество() = 0 Тогда
		Возврат Наборы;
	КонецЕсли;
	
	ЮТСобытия.ПередВсемиТестамиМодуля(ТестовыйМодуль);
	
	Если ЕстьОшибки(ТестовыйМодуль) Тогда
		СкопироватьОшибкиВ(Наборы, ТестовыйМодуль.Ошибки);
		Возврат Наборы;
	КонецЕсли;
	
	Для Каждого Набор Из Наборы Цикл
		
		Результат = ВыполнитьНаборТестов(Набор, ТестовыйМодуль);
		
		Если Результат <> Неопределено Тогда
			Набор.Тесты = Результат;
		КонецЕсли;
		
	КонецЦикла;
	
	ЮТСобытия.ПослеВсехТестовМодуля(ТестовыйМодуль);
	
	Если ЕстьОшибки(ТестовыйМодуль) Тогда
		СкопироватьОшибкиВ(Наборы, ТестовыйМодуль.Ошибки);
	КонецЕсли;
	
	ТестовыйМодуль.Ошибки.Очистить(); // Эти ошибки используются как буфер и уже скопированы в наборы, но ломают последующие наборы
	
	Возврат Наборы;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ВыполнитьНаборТестов(Набор, ТестовыйМодуль)
	
	Набор.ДатаСтарта = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЮТСобытия.ПередТестовымНабором(ТестовыйМодуль, Набор);
	
	Если ЕстьОшибки(Набор) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результаты = Новый Массив();
	
	Для Каждого Тест Из Набор.Тесты Цикл

		ВТранзакции = Ложь;
		ПередКаждымТестом(ТестовыйМодуль, Набор, Тест, ВТранзакции);
		
		Тест.ДатаСтарта = ТекущаяУниверсальнаяДатаВМиллисекундах();
		ВыполнитьТестовыйМетод(Тест);
		Тест.Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - Тест.ДатаСтарта;
		
		ПослеКаждогоТеста(ТестовыйМодуль, Набор, Тест, ВТранзакции);
		
		Тест.Статус = ЮТРегистрацияОшибок.СтатусВыполненияТеста(Тест);
		Результаты.Добавить(Тест);
		
	КонецЦикла;
	
	ЮТСобытия.ПослеТестовогоНабора(ТестовыйМодуль, Набор);
	
	Набор.Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - Набор.ДатаСтарта;
		
	Возврат Результаты;
	
КонецФункции

Процедура ПередКаждымТестом(ТестовыйМодуль, Набор, Тест, ВТранзакции)
	
#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ТолстыйКлиентУправляемоеПриложение Тогда
	ВТранзакции = ЮТНастройкиВыполнения.ВТранзакции();
	Если ВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
#КонецЕсли
	
	ЮТСобытия.ПередКаждымТестом(ТестовыйМодуль, Набор, Тест);
	
КонецПроцедуры

Процедура ПослеКаждогоТеста(ТестовыйМодуль, Набор, Тест, ВТранзакции)
	
	Если ЮТКонтекст.ДанныеКонтекста() = Неопределено Тогда // Сломан контекст
		ОбновитьПовторноИспользуемыеЗначения();
		ОтменитьТранзакциюТеста(Тест, ВТранзакции);
		ЮТСобытия.ПослеКаждогоТеста(ТестовыйМодуль, Набор, Тест);
	Иначе
		ЮТСобытия.ПослеКаждогоТеста(ТестовыйМодуль, Набор, Тест);
		ОтменитьТранзакциюТеста(Тест, ВТранзакции);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтменитьТранзакциюТеста(Тест, ВТранзакции)
	
#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ТолстыйКлиентУправляемоеПриложение Тогда
	Если ВТранзакции Тогда
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		Иначе
			ЮТРегистрацияОшибок.ЗарегистрироватьПростуюОшибкуВыполнения(Тест, "Обнаружено лишне закрытие транзакции");
		КонецЕсли;
	КонецЕсли;
	
	Пока ТранзакцияАктивна() Цикл
		ОтменитьТранзакцию();
		ЮТРегистрацияОшибок.ЗарегистрироватьПростуюОшибкуВыполнения(Тест, "Обнаружена незакрытая транзакция");
	КонецЦикла;
#КонецЕсли
	
КонецПроцедуры

Функция ЕстьОшибки(Объект)
	
	Возврат ЗначениеЗаполнено(Объект.Ошибки);
	
КонецФункции

Процедура ВыполнитьТестовыйМетод(Тест)
	
	Если ЕстьОшибки(Тест) Тогда
		Возврат;
	КонецЕсли;
	
	СтатусыИсполненияТеста = ЮТФабрика.СтатусыИсполненияТеста();
	Тест.Статус = СтатусыИсполненияТеста.Исполнение;
	
	Ошибка = ЮТОбщий.ВыполнитьМетод(Тест.ПолноеИмяМетода, Тест.Параметры);
	
	Если Ошибка <> Неопределено Тогда
		ЮТРегистрацияОшибок.ЗарегистрироватьОшибкуВыполненияТеста(Тест, Ошибка);
	КонецЕсли;
	
КонецПроцедуры

Процедура СкопироватьОшибкиВ(Объекты, Ошибки)
	
	Для Каждого Объект Из Объекты Цикл
		
		ЮТОбщий.ДополнитьМассив(Объект.Ошибки, Ошибки);
		
		Если Объект.Свойство("Статус") Тогда
			Объект.Статус = ЮТФабрика.СтатусыИсполненияТеста().Сломан;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
