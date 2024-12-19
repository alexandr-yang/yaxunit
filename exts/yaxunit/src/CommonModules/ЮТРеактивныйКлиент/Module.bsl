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

// Это разработка @zeegin(https://github.com/zeegin) aka Ingvar

#Область ПрограммныйИнтерфейс

// Конструктор сообщения, получаемого от реактивного приложения
//
// Возвращаемое значение:
//  Структура:
//  * ИмяСобытия - Строка - для ветвления по событиям
//  * Ид - Строка - Идентификатор сообщения
//  * Значение - Структура, Массив, Число, Строка, Булево, ДвоичныеДанные, Неопределено - параметры события
Функция НовоеСообщение() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ИмяСобытия", "");
	Результат.Вставить("Ид", "");
	Результат.Вставить("Значение", "");
	
	Возврат Результат;
	
КонецФункции

// Перехватыет сообщение из события *ПриНажатии поля HTTP документа и формирует обработку оповещения
// 
// Параметры:
//  ЭтотОбъект - ФормаКлиентскогоПриложения - Форма с которой нужно взаимодействовать
//  ЭлементПолеHTML - ПолеФормы - ПолеHTMLДокумента в которое загружено реактивное приложение
//  ДанныеСобытия - ФиксированнаяСтруктура - См. описание ПриНажатии в синтакс-помощнике
//  СтандартнаяОбработка - Булево - Возвращаемый. Устанавливливается в Ложь если событие реактивного приложения.
//  Обработчик - ОписаниеОповещения - В результат будет возвращен объект См. НовоеСообщение
//
Процедура ОбработатьСообщение(ЭтотОбъект, ЭлементПолеHTML, ДанныеСобытия, СтандартнаяОбработка, Обработчик) Экспорт
	
	ЭлементHTML = ДанныеСобытия["Element"];
	
	Если ЭлементHTML["id"] = "V8WebAppEventRequestForwarder" Тогда
		СтандартнаяОбработка = Ложь;
		
		Сообщение = НовоеСообщение();
		Сообщение.ИмяСобытия = ЭлементHTML.getAttribute("v8eventname");
		Сообщение.Ид = ЭлементHTML.getAttribute("v8uuid");
		
		Тип = ЭлементHTML.getAttribute("v8type");
		Если Тип = "json" Или Тип = "string" Тогда
			Сообщение.Значение = ЮТОбщий.ЗначениеИзJSON(ЭлементHTML["value"]);
		КонецЕсли;
		
		Сообщить(СтрШаблон("Получено %1(%2): %3", Сообщение.ИмяСобытия, Сообщение.Ид, ЭлементHTML["value"]));
		
		ВыполнитьОбработкуОповещения(Обработчик, Сообщение);
	КонецЕсли;
	
КонецПроцедуры

// Ответ на сообщение от реактивного приложения.
// Каждое сообщение должно получить свой ответ! Хотябы пустой.
//
// Параметры:
//  ЭлементПолеHTML - ПолеФормы - ПолеHTMLДокумента в которое загружено реактивное приложение
//  Сообщение - См. НовыйСообщение - Сообщение, на которпое готовится ответ
//  Ответ - Структура, Массив, Число, Строка, Булево, Неопределено - Ответ, который будет отправлен
//
Процедура ОтправитьОтвет(ЭлементПолеHTML, Сообщение, Ответ = Неопределено) Экспорт
	
	Прокси = ГлобальноеСвойство(ЭлементПолеHTML, "V8Proxy");
	
	Пакет = "";
	Если ЗначениеЗаполнено(Ответ) Тогда
		Если ТипЗнч(Ответ) = Тип("Структура")
			Или ТипЗнч(Ответ) = Тип("ФиксированнаяСтруктура")
			Или ТипЗнч(Ответ) = Тип("Соответствие")
			Или ТипЗнч(Ответ) = Тип("ФиксированноеСоответствие")
			Или ТипЗнч(Ответ) = Тип("Массив")
			Или ТипЗнч(Ответ) = Тип("ФиксированныйМассив") Тогда
			
			Пакет = ЮТОбщий.СтрокаJSON(Ответ, Ложь);
		ИначеЕсли ТипЗнч(Ответ) = Тип("ДвоичныеДанные") Тогда
			Пакет = Base64Строка(Ответ)
//		Иначе
//			Пакет = XMLСтрока(Ответ);
		КонецЕсли;
	КонецЕсли;
	
	Прокси.sendResponse(Сообщение.Ид, Пакет);
	
	ЮТЛогирование.Отладка(СтрШаблон("Отправлен ответ %1(%2): %3", Сообщение.ИмяСобытия, Сообщение.Ид, Ответ));
	
КонецПроцедуры

Функция ГлобальноеСвойство(ЭлементПолеHTML, ИмяСвойства) Экспорт
	
	ЭлементHTML = ЭлементПолеHTML.Документ["defaultView"];
	Возврат ЭлементHTML[ИмяСвойства];
	
КонецФункции

#КонецОбласти

