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

// Собирает информацию об окружения, как сервера, так и клиента.
// 
// Возвращаемое значение:
//  Структура - Описание окружения:
// * ВерсияПлатформы - Строка
// * ФайловаяБаза - Булево
// * ОбычноеПриложение - Булево
// * ВебКлиент - Булево
// * ТолстыйКлиент - Булево
// * ЛокальПлатформы - Строка
// * ЛокальИнтерфейса - Строка
// * ОперационнаяСистемаКлиент - Строка - Возможные значения: Linux, Windows, MacOS
// * АрхитектураКлиент - Строка - Возможные значения: x86_64, i386
// * ОперационнаяСистемаСервер - Строка - Возможные значения: Linux, Windows, MacOS
// * АрхитектураСервер - Строка - Возможные значения: x86_64, i386
// * ВстроенныйЯзык - Строка - Возможные значения: ru, en
// * ИнформационнаяСреда - Строка
Функция ОписаниеОкружения() Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	ОписаниеСерверногоОкружения = ЮТМетодыСлужебный.ВызватьФункциюКонфигурацииНаСервере("ЮТОкружениеСлужебныйКлиентСервер",
																						"ОписаниеСерверногоОкружения");
	
	Окружение = Новый Структура;
	Окружение.Вставить("Конфигурация", ОписаниеСерверногоОкружения.Конфигурация);
	Окружение.Вставить("ВерсияКонфигурации", ОписаниеСерверногоОкружения.ВерсияКонфигурации);
	Окружение.Вставить("ВерсияПлатформы", СистемнаяИнформация.ВерсияПриложения);
	Окружение.Вставить("ИнформационнаяСреда", "DEV");
	Окружение.Вставить("ТестовыйДвижок", ОписаниеСерверногоОкружения.ТестовыйДвижок);
	Окружение.Вставить("ВерсияТестовогоДвижка", ОписаниеСерверногоОкружения.ВерсияТестовогоДвижка);
	
	Окружение.Вставить("ЛокальПлатформы", ЛокальПлатформы());
	Окружение.Вставить("ЛокальИнтерфейса", ЛокальИнтерфейса());
	Окружение.Вставить("ВстроенныйЯзык", ОписаниеСерверногоОкружения.ВстроенныйЯзык);
	
	Платформа = Платформа(СистемнаяИнформация);
	Окружение.Вставить("ОперационнаяСистемаКлиент", Платформа.ОперационнаяСистема);
	Окружение.Вставить("АрхитектураКлиент", Платформа.Архитектура);
	
	Окружение.Вставить("ОперационнаяСистемаСервер", ОписаниеСерверногоОкружения.ОперационнаяСистема);
	Окружение.Вставить("АрхитектураСервер", ОписаниеСерверногоОкружения.Архитектура);
	
	Окружение.Вставить("ФайловаяБаза", ЭтоФайловаяБаза());
	Окружение.Вставить("ОбычноеПриложение", Ложь);
	Окружение.Вставить("ВебКлиент", Ложь);
	Окружение.Вставить("ТолстыйКлиент", Ложь);
	
#Если ВебКлиент Тогда
	Окружение.ВебКлиент = Истина;
#ИначеЕсли ТолстыйКлиентОбычноеПриложение Тогда
	Окружение.ОбычноеПриложение = Истина;
	Окружение.ТолстыйКлиент = Истина;
#ИначеЕсли ТолстыйКлиентУправляемоеПриложение Тогда
	Окружение.ТолстыйКлиент = Истина;
#КонецЕсли
	
	//@skip-check use-non-recommended-method
	Окружение.Вставить("ВремяЗапуска", ТекущаяДата()); // BSLLS:DeprecatedCurrentDate-off
	
	//@skip-check constructor-function-return-section
	Возврат Окружение;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура Инициализация(ПараметрыЗапуска) Экспорт
	
	Окружение = ОписаниеОкружения();
	ЮТКонтекстСлужебный.УстановитьЗначениеКонтекста("Окружение", Окружение, Истина);
	
КонецПроцедуры

Функция ЭтоФайловаяБаза()
	
	Возврат СтрНайти(Врег(СтрокаСоединенияИнформационнойБазы()), "FILE=") = 0;
	
КонецФункции

Функция Платформа(СистемнаяИнформация) Экспорт
	
	ОперационнаяСистема = Неопределено;
	Архитектура = Неопределено;
	
	Linux = "Linux";
	Windows = "Windows";
	MacOS = "MacOS";
	
	//@skip-check bsl-variable-name-invalid
	x86 = "i386";
	//@skip-check bsl-variable-name-invalid
	x64 = "x86_64";
	
	ТипКлиентскойПлатформы = СистемнаяИнформация.ТипПлатформы;
	
	Если ТипКлиентскойПлатформы = ТипПлатформы.Linux_x86 Тогда
		ОперационнаяСистема = Linux;
		Архитектура = x86;
	ИначеЕсли ТипКлиентскойПлатформы = ТипПлатформы.Linux_x86_64 Тогда
		ОперационнаяСистема = Linux;
		Архитектура = x64;
	ИначеЕсли ТипКлиентскойПлатформы = ТипПлатформы.Windows_x86 Тогда
		ОперационнаяСистема = Windows;
		Архитектура = x86;
	ИначеЕсли ТипКлиентскойПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		ОперационнаяСистема = Windows;
		Архитектура = x64;
	ИначеЕсли ТипКлиентскойПлатформы = ТипПлатформы.MacOS_x86 Тогда
		ОперационнаяСистема = MacOS;
		Архитектура = x86;
	ИначеЕсли ТипКлиентскойПлатформы = ТипПлатформы.MacOS_x86_64 Тогда
		ОперационнаяСистема = MacOS;
		Архитектура = x64;
	Иначе
		ВызватьИсключение "Неподдерживаемый тип платформы";
	КонецЕсли;
	
	Возврат Новый Структура("ОперационнаяСистема, Архитектура", ОперационнаяСистема, Архитектура);
	
КонецФункции

#Если Сервер Тогда
Функция ОписаниеСерверногоОкружения() Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	Платформа = Платформа(СистемнаяИнформация);
	
	Окружение = Новый Структура;
	Окружение.Вставить("ОперационнаяСистема", Платформа.ОперационнаяСистема);
	Окружение.Вставить("Архитектура", Платформа.Архитектура);
	
	ЭтоРусскийВстроенныйЯзык = Метаданные.ВариантВстроенногоЯзыка = Метаданные.СвойстваОбъектов.ВариантВстроенногоЯзыка.Русский;
	Окружение.Вставить("ВстроенныйЯзык", Формат(ЭтоРусскийВстроенныйЯзык, "БЛ=en; БИ=ru;"));
	
	Расширение = Метаданные.ОбщиеМодули.ЮТОкружениеСлужебныйКлиентСервер.РасширениеКонфигурации();
	Окружение.Вставить("ТестовыйДвижок", Расширение.Имя);
	Окружение.Вставить("ВерсияТестовогоДвижка", Расширение.Версия);
	Окружение.Вставить("Конфигурация", Метаданные.Представление());
	Окружение.Вставить("ВерсияКонфигурации", Метаданные.Версия);
	
	Возврат  Окружение;
	
КонецФункции
#КонецЕсли

Функция ЛокальИнтерфейса()
	
#Если Клиент Тогда
	Возврат ТекущийЯзык();
#Иначе
	Возврат ТекущийЯзык().КодЯзыка;
#КонецЕсли
	
КонецФункции

Функция ЛокальПлатформы()
	
	Возврат ТекущийЯзыкСистемы();
	
КонецФункции

#КонецОбласти
