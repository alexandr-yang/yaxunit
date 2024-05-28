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

#Область ПрограммныйИнтерфейс

// Возвращает информацию об окружении
// 
// Возвращаемое значение:
//  см. ЮТФабрика.НовоеОписаниеОкружения
Функция ОписаниеОкружения() Экспорт
	
	//@skip-check constructor-function-return-section
	Возврат ЮТКонтекстСлужебный.ЗначениеКонтекста("Окружение");
	
КонецФункции

// Версия платформы.
// 
// Возвращаемое значение:
//  Строка - Версия платформы
Функция ВерсияПлатформы() Экспорт
	
	Возврат ЮТСлужебныйПовторногоИспользования.ВерсияПлатформы();
	
КонецФункции

// Используется английский встроенный язык разработки.
// 
// Возвращаемое значение:
//  Булево - Используется английский встроенный язык
Функция ИспользуетсяАнглийскийВстроенныйЯзык() Экспорт
	
	Возврат СтрСравнить(ОписаниеОкружения().ВстроенныйЯзык, "en") = 0;
	
КонецФункции

// Используется русский встроенный язык разработки.
// 
// Возвращаемое значение:
//  Булево - Используется русский встроенный язык
Функция ИспользуетсяРусскийВстроенныйЯзык() Экспорт
	
	Возврат СтрСравнить(ОписаниеОкружения().ВстроенныйЯзык, "ru") = 0;
	
КонецФункции

#КонецОбласти
