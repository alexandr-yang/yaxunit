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

// ИнициализироватьКонтекст
//  Выполняет начальную настройку для работы с хранимым контекстом
Процедура ИнициализироватьКонтекст() Экспорт
	
#Если НЕ Клиент Тогда
	ВызватьИсключение "Метод `ИнициализироватьКонтекст` должен вызываться только с клиента";
#Иначе
	ЮТКонтекстСлужебныйКлиент.ИнициализироватьКонтекст();
	ЮТКонтекстСлужебныйВызовСервера.ИнициализироватьКонтекст();
	ОбновитьПовторноИспользуемыеЗначения();
#КонецЕсли
	
КонецПроцедуры

// ДанныеКонтекста
//  Возвращает хранимые данные контекста.
//  Существует отдельно контекст сервера, отдельно клиента, эти контексты никак не связаны и никак не синхронизируются
// Возвращаемое значение:
//  Структура - Данные контекста
Функция ДанныеКонтекста() Экспорт
	
#Если Клиент Тогда
	Возврат ЮТКонтекстСлужебныйКлиент.ДанныеКонтекста();
#Иначе
	//@skip-check constructor-function-return-section
	Возврат ЮТКонтекстСлужебныйВызовСервера.ДанныеКонтекста();
#КонецЕсли
	
КонецФункции

// ЗначениеКонтекста
//  Возвращает значение вложенного контекста, вложенного реквизита контекста
// Параметры:
//  ИмяРеквизита - Строка - Имя реквизита/вложенного контекста
//  ПолучитьССервера - Булево - Получить значение из серверного контекста
// Возвращаемое значение:
//  - Структура - Значение реквизита/вложенного контекста
// 	- Неопределено
Функция ЗначениеКонтекста(ИмяРеквизита, ПолучитьССервера = Ложь) Экспорт
	
#Если Клиент Тогда
	Если ПолучитьССервера Тогда
		//@skip-check constructor-function-return-section
		Возврат ЮТКонтекстСлужебныйВызовСервера.ЗначениеКонтекста(ИмяРеквизита);
	КонецЕсли;
#КонецЕсли
	
	Объект = ДанныеКонтекста();
	
	Если Объект = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Ключи = СтрРазделить(ИмяРеквизита, ".");
	Для Инд = 0 По Ключи.Количество() - 2 Цикл
		Объект = Объект[Ключи[Инд]];
	КонецЦикла;
	
	//@skip-check constructor-function-return-section
	Возврат ЮТКоллекции.ЗначениеСтруктуры(Объект, Ключи[Ключи.ВГраница()]);

КонецФункции

// УстановитьЗначениеКонтекста
// Устанавливает значение вложенного контекста, вложенного реквизита контекста
// 
// Параметры:
//  ИмяРеквизита - Строка - Имя реквизита/вложенного контекста
//  Значение - Произвольный - Новое значение реквизита/вложенного контекста
//  УстановитьНаСервер - Булево - Установить также на сервер
Процедура УстановитьЗначениеКонтекста(Знач ИмяРеквизита, Знач Значение, Знач УстановитьНаСервер = Ложь) Экспорт
	
	ДанныеКонтекста = ДанныеКонтекста();
	
	Объект = ДанныеКонтекста;
	Ключи = СтрРазделить(ИмяРеквизита, ".");
	Для Инд = 0 По Ключи.Количество() - 2 Цикл
		Объект = Объект[Ключи[Инд]];
	КонецЦикла;
	
	Объект.Вставить(Ключи[Ключи.ВГраница()], Значение);
	
#Если НЕ Сервер Тогда
	Если УстановитьНаСервер Тогда
		ЮТКонтекстСлужебныйВызовСервера.УстановитьЗначениеКонтекста(ИмяРеквизита, Значение);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

// КонтекстТеста
//  Возвращает структуру, в которой можно хранить данные используемые в тесте
//  Данные живут в рамках одного теста, но доступны в обработчиках событий `ПередКаждымТестом` и `ПослеКаждогоТеста`
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеКаждогоТеста`
// Возвращаемое значение:
//  - Структура - Контекст теста
//  - Неопределено - Если метод вызывается за рамками теста
Функция КонтекстТеста() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаТеста());
	
КонецФункции

// КонтекстНабора
//  Возвращает структуру, в которой можно хранить данные используемые в тестах набора
//  Данные живут в рамках одного набора тестов (данные между клиентом и сервером не синхронизируются)
//  Доступны в каждом тесте набора и в обработчиках событий 
//  	+ `ПередТестовымНабором`
//  	+ `ПослеТестовогоНабора`
//  	+ `ПередКаждымТестом`
//  	+ `ПослеКаждогоТеста`
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеКаждогоТеста`
// Возвращаемое значение:
//  - Структура - Контекст набора тестов
//  - Неопределено - Если метод вызывается за рамками тестового набора
Функция КонтекстНабора() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаНабораТестов());
	
КонецФункции

// КонтекстМодуля
//  Возвращает структуру, в которой можно хранить данные используемые в тестах модуля
//  Данные живут в рамках одного тестового модуля (данные между клиентом и сервером не синхронизируются)
//  Доступны в каждом тесте модуля и в обработчиках событий 
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеВсехТестов`
// Возвращаемое значение:
//  - Структура - Контекст тестового модуля
//  - Неопределено - Если метод вызывается за рамками тестового модуля
Функция КонтекстМодуля() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаМодуля());
	
КонецФункции

Функция ГлобальныеНастройкиВыполнения() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяГлобальныеНастройкиВыполнения());
	
КонецФункции

// КонтекстПроверки
//  Возвращает служебный контекста, данные выполняемой проверки
// Возвращаемое значение:
//  Неопределено, Структура - Контекст проверки
Функция КонтекстПроверки() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаУтверждений());
	
КонецФункции

// КонтекстЧитателя
//  Возвращает служебный контекста, данные необходимые на этапе загрузки тестов
// Возвращаемое значение:
//  Неопределено, Структура - Контекст проверки
Функция КонтекстЧитателя() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаЧитателя());
	
КонецФункции

// КонтекстЧитателя
//  Возвращает служебный контекста, данные используемые исполнителем тестов
// Возвращаемое значение:
//  см. ЮТФабрикаСлужебный.НовыйКонтекстИсполнения
Функция КонтекстИсполнения() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЗначениеКонтекста(ИмяКонтекстаИсполнения());
	
КонецФункции

// Контекст исполнения текущего уровня.
// 
// Возвращаемое значение:
//  - Неопределено
//  - См. ЮТФабрикаСлужебный.ОписаниеТестовогоМодуля
//  - См. ЮТФабрикаСлужебный.ОписаниеИсполняемогоНабораТестов
//  - См. ЮТФабрикаСлужебный.ОписаниеИсполняемогоТеста
Функция КонтекстИсполненияТекущегоУровня() Экспорт
	
	Уровни = ЮТФабрика.УровниИсполнения();
	КонтекстИсполнения = КонтекстИсполнения();
	
	Если КонтекстИсполнения.Уровень = Уровни.Модуль Тогда
		
		Возврат КонтекстИсполнения.Модуль;
		
	ИначеЕсли КонтекстИсполнения.Уровень = Уровни.НаборТестов Тогда
		
		Возврат КонтекстИсполнения.Набор;
		
	ИначеЕсли КонтекстИсполнения.Уровень = Уровни.Тест Тогда
		
		Возврат КонтекстИсполнения.Тест;
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции

Функция ОписаниеКонтекста() Экспорт
	
	Описание = Новый Структура;
	
	Возврат Описание;
	
КонецФункции

Процедура УстановитьКонтекстУтверждений(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаУтверждений(), ДанныеКонтекста);
	
КонецПроцедуры

Процедура УстановитьКонтекстНабораТестов() Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаНабораТестов(), Новый Структура);
	
КонецПроцедуры

Процедура УстановитьКонтекстМодуля() Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаМодуля(), Новый Структура);
	
КонецПроцедуры

Процедура УстановитьКонтекстТеста() Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаТеста(), Новый Структура);
	
КонецПроцедуры

Процедура УстановитьКонтекстЧитателя(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаЧитателя(), ДанныеКонтекста, Истина);
	
КонецПроцедуры

Процедура УстановитьКонтекстИсполнения(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаИсполнения(), ДанныеКонтекста, Истина);
	
КонецПроцедуры

Процедура УстановитьГлобальныеНастройкиВыполнения(Знач Настройки) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяГлобальныеНастройкиВыполнения(), Настройки, Истина);
	
КонецПроцедуры

Процедура УдалитьКонтекст() Экспорт
	
#Если Клиент Тогда
	ЮТКонтекстСлужебныйКлиент.УдалитьКонтекст();
#КонецЕсли
	ЮТКонтекстСлужебныйВызовСервера.УдалитьКонтекст();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИмяКонтекстаУтверждений()
	
	Возврат "КонтекстУтверждения";
	
КонецФункции

Функция ИмяКонтекстаНабораТестов()
	
	Возврат "КонтекстНабора";
	
КонецФункции

Функция ИмяКонтекстаМодуля()
	
	Возврат "КонтекстМодуля";
	
КонецФункции

Функция ИмяКонтекстаТеста()
	
	Возврат "КонтекстТеста";
	
КонецФункции

Функция ИмяКонтекстаЧитателя()
	
	Возврат "КонтекстЧитателя";
	
КонецФункции

Функция ИмяГлобальныеНастройкиВыполнения()
	
	Возврат "ГлобальныеНастройкиВыполнения";
	
КонецФункции

Функция ИмяКонтекстаИсполнения()
	
	Возврат "КонтекстИсполнения";
	
КонецФункции

#КонецОбласти
