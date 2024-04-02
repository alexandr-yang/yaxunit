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

Процедура ИсполняемыеСценарии() Экспорт
	
	ЮТТесты.ЗависитОт().ФайлыПроекта(".gitignore")
		.ДобавитьТест("УникальнаяЗависимость")
		.ДобавитьТест("ДанныеЗависимости").ЗависитОт().ФайлыПроекта(".gitignore")
		.ДобавитьТест("ДанныеЗависимости_Каталог").ЗависитОт().ФайлыПроекта(".github")
		.ДобавитьТест("ДанныеЗависимости_НеизвестныйФайл").ЗависитОт().ФайлыПроекта("НеизвестныйФайл")
	;
	
КонецПроцедуры

Процедура УникальнаяЗависимость() Экспорт
	
	Зависимости = Новый Соответствие();
	
	Зависимость1 = ЮТЗависимостиСлужебный.УникальнаяЗависимость(Зависимости, НоваяЗависимость("Зависимость 1"));
	Зависимость2 = ЮТЗависимостиСлужебный.УникальнаяЗависимость(Зависимости, НоваяЗависимость("ЗавИсимость 1"));
	Зависимость3 = ЮТЗависимостиСлужебный.УникальнаяЗависимость(Зависимости, НоваяЗависимость("ЗависИМОСТЬ 1", "Модуль.Метод"));
	Зависимость4 = ЮТЗависимостиСлужебный.УникальнаяЗависимость(Зависимости, НоваяЗависимость("Зависимость 1", , "Строка 1"));
	Зависимость5 = ЮТЗависимостиСлужебный.УникальнаяЗависимость(Зависимости, НоваяЗависимость("Зависимость 1", , "Строка 1"));
	
	ЮТест.ОжидаетЧто(Зависимости)
		.ИмеетДлину(2);
	
	ЮТест.ОжидаетЧто(Зависимость1)
		.ИмеетТип("ФиксированнаяСтруктура")
		.Равно(Зависимость2)
		.Равно(Зависимость3)
		.НеРавно(Зависимость4);
	ЮТест.ОжидаетЧто(Зависимость4, "Зависимость с параметром")
		.ИмеетТип("ФиксированнаяСтруктура")
		.Равно(Зависимость5)
	
КонецПроцедуры

Процедура ДанныеЗависимости() Экспорт
	
	ПолноеИмяФайла = ЮТест.Зависимость(ЮТЗависимости.ФайлыПроекта(".gitignore")).ПолноеИмя;
	
	ЮТест.ОжидаетЧто(ЮТФайлы.Существует(ПолноеИмяФайла), "Файл каталога проекта не существует")
		.ЭтоИстина();
	
	Данные = ЮТОбщий.ДанныеТекстовогоФайла(ПолноеИмяФайла);
	ЮТест.ОжидаетЧто(Данные, "Содержимое файла")
		.Содержит("ConfigDumpInfo.xml");
	
КонецПроцедуры

Процедура ДанныеЗависимости_НеизвестныйФайл() Экспорт
	
	ВызватьИсключение "Тест не должен быть вызван";
	
КонецПроцедуры

Процедура ДанныеЗависимости_Каталог() Экспорт
	
	ПолноеИмя = ЮТест.Зависимость(ЮТЗависимости.ФайлыПроекта(".github")).ПолноеИмя;
	
	ЮТест.ОжидаетЧто(ЮТФайлы.Существует(ПолноеИмя), "Каталог проекта не доступен")
		.ЭтоИстина();
	
	ЮТест.ОжидаетЧто(ЮТФайлы.ЭтоКаталог(ПолноеИмя), "Это не каталог")
		.ЭтоИстина();
	
	ЮТест.ОжидаетЧто(ЮТФайлы.Существует(ЮТФайлы.ОбъединитьПути(ПолноеИмя, "workflows", "main-build.yml")), "Файл проекта не доступен")
		.ЭтоИстина();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция НоваяЗависимость(Идентификатор, Метод = Неопределено, Параметр1 = Неопределено, Параметр2 = Неопределено)
	
	Описание = ЮТФабрика.НовоеОписаниеЗависимости();
	Описание.Идентификатор = Идентификатор;
	Описание.МетодРеализации = ?(Метод = Неопределено, Идентификатор, Метод);
	
	Если Параметр1 <> Неопределено Тогда
		Описание.Параметры.Добавить(Параметр1);
	КонецЕсли;
	
	Если Параметр2 <> Неопределено Тогда
		Описание.Параметры.Добавить(Параметр2);
	КонецЕсли;
	
	Возврат Описание;
	
КонецФункции

#КонецОбласти
