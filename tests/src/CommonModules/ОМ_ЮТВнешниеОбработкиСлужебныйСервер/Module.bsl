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
	
	ЮТТесты
		.ДобавитьТест("СкомпилирватьВнешнуюОбработку")
	;
	
КонецПроцедуры

Процедура СкомпилирватьВнешнуюОбработку() Экспорт
	
	Значение = ЮТест.Данные().СлучайнаяСтрока();
	Алгоритм = СтрШаблон("Перем Реквизит Экспорт;
						 |Реквизит = ""%1"";", Значение);
	ИмяФайлаОбработки = ЮТВнешниеОбработкиСлужебныйСервер.СкомпилирватьВнешнуюОбработку(Алгоритм);
	
	ЮТест.ОжидаетЧто(ИмяФайлаОбработки)
		.Заполнено();
	ЮТест.ОжидаетЧто(ЮТФайлы.Существует(ИмяФайлаОбработки), "Не существует файл созданной обработки")
		.ЭтоИстина();
		
	Обработка = ВнешниеОбработки.Создать(ИмяФайлаОбработки, Ложь);
	
	ЮТест.ОжидаетЧто(Обработка)
		.Свойство("Реквизит")
			.Равно(Значение);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#КонецОбласти
