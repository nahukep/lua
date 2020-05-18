script_name('MoD-Helper')
script_authors('Shifu Murano', 'Frapsy', 'Sergey Parhutik')
script_description('Ministry of Defence Helper.')
script_version_number(28)
script_version("0.2.8")
script_properties("work-in-pause")

--memory.fill(sampGetBase() + 0x9D31A, 0x90, 12, true)
--memory.fill(sampGetBase() + 0x9D329, 0x90, 12, true)
-- блок худа сампу


local res = pcall(require, "lib.moonloader")
assert(res, 'Library lib.moonloader not found')
---------------------------------------------------------------
local res, ffi = pcall(require, 'ffi')
assert(res, 'Library ffi not found')
---------------------------------------------------------------
local dlstatus = require('moonloader').download_status
---------------------------------------------------------------
local res = pcall(require, 'lib.sampfuncs')
assert(res, 'Library lib.sampfuncs not found')
---------------------------------------------------------------
local res, sampev = pcall(require, 'lib.samp.events')
assert(res, 'Library SAMP Events not found')
---------------------------------------------------------------
local res, bass = pcall(require, "lib.bass")
assert(res, 'Library BASS not found.')
---------------------------------------------------------------
local res, key = pcall(require, "vkeys")
assert(res, 'Library vkeys not found')
---------------------------------------------------------------
local res, aes = pcall(require, "aeslua")
assert(res, 'Library aeslua not found')
---------------------------------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, 'Library imgui not found')
---------------------------------------------------------------
local res, encoding = pcall(require, "encoding")
assert(res, 'Library encoding not found')
---------------------------------------------------------------
local res, inicfg = pcall(require, "inicfg")
assert(res, 'Library inicfg not found')
---------------------------------------------------------------
local res, memory = pcall(require, "memory")
assert(res, 'Library memory not found')
---------------------------------------------------------------
local res, rkeys = pcall(require, "rkeys")
assert(res, 'Library rkeys not found')
---------------------------------------------------------------
local res, hk = pcall(require, 'lib.imcustom.hotkey')
assert(res, 'Library imcustom not found')
---------------------------------------------------------------
local res, https = pcall(require, 'ssl.https')
assert(res, 'Library ssl.https not found')
---------------------------------------------------------------
local lanes = require('lanes').configure()
---------------------------------------------------------------
local res, sha1 = pcall(require, 'sha1')
assert(res, 'Library sha1 not found')
---------------------------------------------------------------
local res, basexx = pcall(require, 'basexx')
assert(res, 'Library basexx not found')
---------------------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, 'Library faIcons not found')
-- ---------------------------------------------------------------
-- local res, effil = pcall(require, 'effil')
-- assert(res, 'Library effil not found')



encoding.default = 'CP1251'
u8 = encoding.UTF8

ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	
	void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
	uint32_t __stdcall CoInitializeEx(void*, uint32_t);

	int __stdcall GetVolumeInformationA(
    const char* lpRootPathName,
    char* lpVolumeNameBuffer,
    uint32_t nVolumeNameSize,
    uint32_t* lpVolumeSerialNumber,
    uint32_t* lpMaximumComponentLength,
    uint32_t* lpFileSystemFlags,
    char* lpFileSystemNameBuffer,
    uint32_t nFileSystemNameSize
);
]]
local LocalSerial = ffi.new("unsigned long[1]", 0)
ffi.C.GetVolumeInformationA(nil, nil, 0, LocalSerial, nil, nil, nil, 0)
LocalSerial = LocalSerial[0]

local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

-- свалка переменных
mlogo, errorPic, classifiedPic, pentagonPic, accessDeniedPic, gameServer, nasosal_rang = nil, nil, nil, nil, nil, nil -- картинки
srv, arm = nil, nil -- номера сервера и армии
whitelist, superID, vigcout, narcout, order = 0, 0, 0, 0, 0 -- значения по дефолту для "информация"
regDialogOpen, regAcc, UpdateNahuy, checking, getLeader, checkupd = false, false, false, false, false -- bool переменные для работы с диалогами
ScriptUse = 3 -- для цикла
armourStatus = 0 -- статус броника(снят/надет)
offscript = 0 -- переменная для подсчета количества нажатий на кнопку "выключить скрипта"
pentcout, pentsrv, pentinv, pentuv = 0,0,0,0 -- дефолт значения /base
regStatus = false -- проверяет пройденность получения инфы 
gmsg = false -- проверка на разрешение чекать на ВК
gosButton, AccessBe = true -- проверка на отправку госки 
dostupLvl = nil -- уровень доступа
activated = nil -- ограничение функционала, если скрипт не соединился с БД
isLocalPlayerSoldier = false -- проверка на состояние в МО по диалогу статы
getMOLeader = "Not Registred" -- МО
getSVLeader = "Not Registred" -- СВ
getVVSLeader = "Not Registred" -- ВВС
getVMFLeader = "Not Registred" -- ВМФ
pidr = false -- для черного спика
errorSearch = nil -- если не смогли найти в пентагоне
vkinf = "Disabled by developer"
developMode = "Local Edition"
--assTakeDamage = 0 -- количество раз, сколько игрок получил дамага
flymode = 0 -- камхак
isPlayerSoldier = false -- проверка на состояние в МО по данным из БД
speed = 0.2 -- скорость камхака
bstatus = 0 -- для чекера на ЧС, 1 если в ЧСе найден
offMask = true -- таймер маски
enableStrobes = false -- стробоскопы
state = false -- автострой если не ошибаюсь
--assDmg = false -- для отправки репорта на дмщика от координатора
--dmInfo = false -- вывод инфы о дме в окно имгуи
keystatus = false -- проверка на воспроизведение бинда
workpause = false -- проверка на включенность костыля для работы скрипта при свернутой игре для vkint
mouseCoord = false -- проверка на статус перемещения окна информера
token = 1 -- токен
mouseCoord2 = false -- перемещение автостроя
mouseCoord3 = false -- перемещение координатора
getServerColored = '' -- переменная в которой храним все ники пользователей по серверу для покраса в чате

blackbase = {} -- для черного списка
names = {} -- для автростроя
SecNames = {}
SecNames2 = {}


-- переменные для шпоры, если не ошибаюсь, то есть лишние
files							= {}
window_file						= {}
menu_spur						= imgui.ImBool(false)
name_add_spur					= imgui.ImBuffer(256)
name_edit_spur					= imgui.ImBuffer(256)
find_name_spur					= imgui.ImBuffer(256)
find_text_spur					= imgui.ImBuffer(256)
edit_text_spur					= imgui.ImBuffer(65536)
edit_size_x						= imgui.ImInt(-1)
edit_size_y						= imgui.ImInt(-1)
russian_characters				= { [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я' }
magicChar						= { '\\', '/', ':', '*', '?', '"', '>', '<', '|' }
	
-- настройки игрока
local SET = {
 	settings = {
		autologin = false,
		autogoogle = false,
		autopass = '',
		googlekey = '',
		smssound = true,
		rpFind = false,
		rpinv = true,
		rpuninv = true,
		rpuninvoff = true,
		rpskin = true,
		rprang = true,
		rptime = false,
		timerp = 'Best Man',
		timecout = false,
		rpblack = false,
		gangzones = false,
		zones = false,
		assistant = false,
		tag = '',
		enable_tag = false,
		gos1 = '',
		gos2 = '',
		gos3 = '',
		gos4 = '',
		gos5 = '',
		lady = false,
		gateOn = false,
		lockCar = false,
		strobes = false,
		armOn = false,
		ads = false,
		chatInfo = false,
		timeToZp = false,
		timeBrand = '',
		keyT = false,
		screenSave = false,
		phoneModel = '',
		inComingSMS = false,
		specUd = false,
		infoX = 0,
		infoY = 0,
		infoX2 = 0,
		infoY2 = 0,
		spOtr = '',
		marker = true,
		gnewstag = 'МО',
		timefix = 3,
		enableskin = false,
		skin = 1,
	},
	vkint = {
		zp = false,
		nickdetect = false,
		pushv = false,
		smsinfo = false,
		remotev = false,
		getradio = false,
		familychat = false
	},
	assistant = {
		asX = 1,
		asY = 1
	},
	informer = {
		zone = true,
		hp = true,
		armour = true,
		city = true,
		kv = true,
		time = true,
		rajon = true,
		mask = true
	}
}


local SeleList = {"Досье", "Сведения", "Пентагон"} -- список менюшек для блока "информация"

-- это делалось если не ошибаюсь для выделения выбранного пункта
local SeleListBool = {}
for i = 1, #SeleList do
	SeleListBool[i] = imgui.ImBool(false)
end

-- массив для окон
local win_state = {}
win_state['main'] = imgui.ImBool(false)
win_state['info'] = imgui.ImBool(false)
win_state['settings'] = imgui.ImBool(false)
win_state['hotkeys'] = imgui.ImBool(false)
win_state['leaders'] = imgui.ImBool(false)
win_state['help'] = imgui.ImBool(false)
win_state['about'] = imgui.ImBool(false)
win_state['update'] = imgui.ImBool(false)
win_state['player'] = imgui.ImBool(false)
win_state['base'] = imgui.ImBool(false)
win_state['informer'] = imgui.ImBool(false)
win_state['regst'] = imgui.ImBool(false)
win_state['renew'] = imgui.ImBool(false)
win_state['find'] = imgui.ImBool(false)
win_state['ass'] = imgui.ImBool(false)
win_state['leave'] = imgui.ImBool(false)

-- временные переменные, которым не требуется сохранение
pozivnoy = imgui.ImBuffer(256) -- позывной в меню взаимодействия
cmd_name = imgui.ImBuffer(256) -- название команды
cmd_text = imgui.ImBuffer(65536) -- текст бинда
searchn = imgui.ImBuffer(256) -- поиск ника в пентагоне
specOtr = imgui.ImBuffer(256) -- спец.отряд для нашивки(вроде)
weather = imgui.ImInt(-1) -- установка погоды
gametime = imgui.ImInt(-1) -- установка времени 
vkid = imgui.ImInt(1) -- назначаем vkid при регистрации
binddelay = imgui.ImInt(3) -- задержка биндера

-- удаление файла клавиш, делаю только тогда, когда добавляю новые клавиши. P.S. удаляет как когда
if doesFileExist(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind") then 
	os.remove(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind")
end

-- Собственно тут ебошим клавиши для биндера и обычные, ничего необычного, а исток всего этого - PerfectBinder хомяка, ибо только там было показано, как более менее юзать imcustom/rkeys.
hk._SETTINGS.noKeysMessage = u8("Пусто")
local bfile = getWorkingDirectory() .. "\\config\\MoD-Helper\\key.bind" -- путь к файлу для хранения клавиш
local tBindList = {}
if doesFileExist(bfile) then
	local fkey = io.open(bfile, "r")
	if fkey then
		tBindList = decodeJson(fkey:read("a*"))
		fkey:close()
	end
else
	tBindList = { 
		[1] = { text = "Тайм", v = {} },
		[2] = { text = "/gate", v = {} },
		[3] = { text = "Сотрудники", v = {} },
		[4] = { text = "Carlock", v = {} },
		[5] = { text = "In SMS", v = {} },
		[6] = { text = "Out SMS", v = {} },
		[7] = { text = "Реконнект", v = {} },
		[8] = { text = "АвтоСтрой", v = {} },
		[9] = { text = "P.E.S. Help", v = {} },
		[10] = { text = "Принять P.E.S.", v = {} },
		[11] = { text = "Fuck Pe4enka.", v = {} },
		[12] = { text = "Снять маркер", v = {} },
		[13] = { text = "Меню скрипта", v = {} }
	}
end


local bindfile = getWorkingDirectory() .. '\\config\\MoD-Helper\\binder.bind'
local mass_bind = {}
if doesFileExist(bindfile) then
	local fbind = io.open(bindfile, "r")
	if fbind then
		mass_bind = decodeJson(fbind:read("a*"))
		fbind:close()
	end
else
	mass_bind = {
		[1] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[2] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[3] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[4] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[5] = { cmd = "-", v = {}, text = "Any text", delay = 3 }
	}
end


-----------------------------------------------------------------------------------
------------------------------- ФИКСЫ И ПОДОБНАЯ ХУЙНЯ ----------------------------
-----------------------------------------------------------------------------------

-- Фикс зеркального бага alt+tab(черный экран или же какая то хуйня в виде зеркал на экране после разворота в инте)
writeMemory(0x555854, 4, -1869574000, true)
writeMemory(0x555858, 1, 144, true)

-- функция быстрого прогруза игры, кепчик чтоль автор.. Не помню
function patch()
	if memory.getuint8(0x748C2B) == 0xE8 then
		memory.fill(0x748C2B, 0x90, 5, true)
	elseif memory.getuint8(0x748C7B) == 0xE8 then
		memory.fill(0x748C7B, 0x90, 5, true)
	end
	if memory.getuint8(0x5909AA) == 0xBE then
		memory.write(0x5909AB, 1, 1, true)
	end
	if memory.getuint8(0x590A1D) == 0xBE then
		memory.write(0x590A1D, 0xE9, 1, true)
		memory.write(0x590A1E, 0x8D, 4, true)
	end
	if memory.getuint8(0x748C6B) == 0xC6 then
		memory.fill(0x748C6B, 0x90, 7, true)
	elseif memory.getuint8(0x748CBB) == 0xC6 then
		memory.fill(0x748CBB, 0x90, 7, true)
	end
	if memory.getuint8(0x590AF0) == 0xA1 then
		memory.write(0x590AF0, 0xE9, 1, true)
		memory.write(0x590AF1, 0x140, 4, true)
	end
end
patch()

-----------------------------------------------------------------------------------
-------------------------- ФУНКЦИИ СКРИПТА И ВСЕ ЧТО ПО НИМ -----------------------
-----------------------------------------------------------------------------------


function new_style() -- паблик дизайн андровиры, который юзался в скрипте ранее

	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 5.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	style.WindowTitleAlign = ImVec2(0.5, 0.5)


	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 0.50)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 0.80)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	--colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.TitleBgCollapsed] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 0.50) 	
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 0.50)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    --colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    --colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.70)
    colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.80)

	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.98)
    --colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBg] = ImVec4(0.13, 0.12, 0.15, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 0.50)

end

function apply_custom_style() -- дизайн imgui, цветовая схема уникальная в том плане, что ее нет в сети и сделана руками

	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 5.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	style.WindowTitleAlign = ImVec2(0.5, 0.5)

	colors[clr.Text] = ImVec4(0.71, 0.94, 0.93, 1.00) 
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00) 
	colors[clr.WindowBg] = ImVec4(0.00, 0.06, 0.08, 0.91) 
	colors[clr.ChildWindowBg] = ImVec4(0.00, 0.07, 0.07, 0.91) 
	colors[clr.PopupBg] = ImVec4(0.02, 0.08, 0.09, 0.94) 
	colors[clr.Border] = ImVec4(0.04, 0.60, 0.55, 0.88) 
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00) 
	colors[clr.FrameBg] = ImVec4(0.02, 0.60, 0.56, 0.49) 
	colors[clr.FrameBgHovered] = ImVec4(0.10, 0.63, 0.69, 0.72) 
	colors[clr.FrameBgActive] = ImVec4(0.04, 0.54, 0.60, 1.00) 
	colors[clr.TitleBg] = ImVec4(0.00, 0.26, 0.30, 0.94) 
	colors[clr.TitleBgActive] = ImVec4(0.00, 0.26, 0.29, 0.94) 
	colors[clr.TitleBgCollapsed] = ImVec4(0.01, 0.28, 0.40, 0.66) 
	colors[clr.MenuBarBg] = ImVec4(0.00, 0.22, 0.22, 0.73) 
	colors[clr.ScrollbarBg] = ImVec4(0.01, 0.44, 0.43, 0.60) 
	colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.93, 1.00, 0.31) 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.17, 0.64, 0.79, 1.00) 
	colors[clr.ScrollbarGrabActive] = ImVec4(0.01, 0.48, 0.57, 1.00) 
	colors[clr.ComboBg] = ImVec4(0.01, 0.51, 0.50, 0.74) 
	colors[clr.CheckMark] = ImVec4(0.17, 0.87, 0.85, 0.62) 
	colors[clr.SliderGrab] = ImVec4(0.10, 0.84, 0.87, 0.31) 
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.Button] = ImVec4(0.09, 0.70, 0.75, 0.48) 
	colors[clr.ButtonHovered] = ImVec4(0.15, 0.72, 0.75, 0.69) 
	colors[clr.ButtonActive] = ImVec4(0.13, 0.92, 0.98, 0.47) 
	colors[clr.Header] = ImVec4(0.09, 0.65, 0.69, 0.47) 
	colors[clr.HeaderHovered] = ImVec4(0.07, 0.54, 0.58, 0.47) 
	colors[clr.HeaderActive] = ImVec4(0.06, 0.50, 0.53, 0.47) 
	colors[clr.Separator] = ImVec4(0.00, 0.20, 0.23, 1.00) 
	colors[clr.SeparatorHovered] = ImVec4(0.00, 0.20, 0.23, 1.00) 
	colors[clr.SeparatorActive] = ImVec4(0.00, 0.20, 0.23, 1.00) 
	colors[clr.ResizeGrip] = ImVec4(0.06, 0.90, 0.78, 0.16) 
	colors[clr.ResizeGripHovered] = ImVec4(0.04, 0.54, 0.48, 1.00) 
	colors[clr.ResizeGripActive] = ImVec4(0.01, 0.28, 0.41, 1.00) 
	colors[clr.CloseButton] = ImVec4(0.00, 0.94, 0.96, 0.25) 
	colors[clr.CloseButtonHovered] = ImVec4(0.15, 0.63, 0.61, 0.39) 
	colors[clr.CloseButtonActive] = ImVec4(0.15, 0.63, 0.61, 0.39) 
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63) 
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63) 
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43) 
	colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.80)

end
apply_custom_style()

function files_add() -- функция подгрузки медиа файлов
	print("Проверка целостности файлов")
	if not doesDirectoryExist("moonloader\\MoD-Helper") then print("Создаю MoD-Helper/") createDirectory("moonloader\\MoD-Helper") end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\shpora") then print("Создаю MoD-Helper/shpora") createDirectory('moonloader\\MoD-Helper\\shpora') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\audio") then print("Создаю MoD-Helper/audio") createDirectory('moonloader\\MoD-Helper\\audio') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\images") then print("Создаю MoD-Helper/images") createDirectory('moonloader\\MoD-Helper\\images') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\files") then print("Создаю MoD-Helper/files") createDirectory("moonloader\\MoD-Helper\\files") end

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\ad.wav') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\avik.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\base.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\sms.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\crash.mp3') then
		async_http_request('GET', 'https://frank09.000webhostapp.com/files/ad.wav', nil, 
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/ad.wav', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[ad.wav]: Success")
		end,
		function(err)
			print("Audio download[ad.wav]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/base.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/base.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[base.mp3]: Success")
		end,
		function(err)
			print("Audio download[base.mp3]: "..err)
		end)
		
		async_http_request('GET', 'https://frank09.000webhostapp.com/files/avik.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/avik.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/crash.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/crash.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/sms.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/sms.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)
	end

	if not doesDirectoryExist("moonloader\\MoD-Helper\\images\\skins") then
		print("Создаю MoD-Helper/images/skins")
		createDirectory("moonloader\\MoD-Helper\\images\\skins")
	end
		
	lua_thread.create(function()
		for i = 1, 311 do
			if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png') then
				if i ~= 53 and i ~= 74 then
					downloadUrlToFile('https://files.advance-rp.ru/media/skins/'..i..'.png', getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png')
					print('Skinload: Skin: '..i..'/311 loaded')
					repeat 
						wait(0)
					until doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png')
				end
			end
		end
	end)

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\img.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\errorPic.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\classified.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\pentagon.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\access_denied.png') then
		print("Загружаю системные картинки")
		downloadUrlToFile('https://i.imgur.com/KkOXJJs.png', getWorkingDirectory() .. '/MoD-Helper/images/img.png')
		downloadUrlToFile('https://i.imgur.com/X99DKIb.png', getWorkingDirectory() .. '/MoD-Helper/images/errorPic.png')
		downloadUrlToFile('https://i.imgur.com/fnHuVN3.png', getWorkingDirectory() .. '/MoD-Helper/images/classified.png')
		downloadUrlToFile('https://i.imgur.com/Obl47RD.png', getWorkingDirectory() .. '/MoD-Helper/images/pentagon.png')
		downloadUrlToFile('https://i.imgur.com/jrJVpOS.png', getWorkingDirectory() .. '/MoD-Helper/images/access_denied.png')			
	end
	if not doesDirectoryExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers') then
		print("Создаю MoD-Helper/images/helpers")
		createDirectory('moonloader\\MoD-Helper\\images\\helpers')
	end

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png') then
		print("Загружаю Стефани(майор Фиорентино).")
		downloadUrlToFile('https://i.imgur.com/oHDkTvI.png', getWorkingDirectory() .. '/MoD-Helper/images/helpers/stefani.png')	
	end
	if not doesFileExist(getGameDirectory()..'\\moonloader\\config\\MoD-Helper\\settings.ini') then 
		inicfg.save(SET, 'config\\MoD-Helper\\settings.ini')
	end
end

function rkeys.onHotKey(id, keys) -- эту штучку я не использую, но она помогла запретить юзание клавиш в определенных ситах
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or win_state['base'].v or win_state['update'].v or win_state['player'].v or droneActive or keystatus then
		return false
	end
end

function onHotKey(id, keys) -- функция обработки всех клавиш, которые ток существуют в скрипте благодаря imcustom, rkeys и хомяку
	local sKeys = tostring(table.concat(keys, " "))
	for k, v in pairs(tBindList) do
		if sKeys == tostring(table.concat(v.v, " ")) then
			if k == 1 then -- вбиваем тайм
				sampSendChat("/time")
				return
			elseif k == 2 then -- открываем врата
				if interior ~= 0 and isPlayerSoldier then
					sampAddChatMessage("[Army Assistant]{FFFFFF} Вы находитесь в интерьере, команда недоступна.", 0x046D63) 
				elseif interior == 0 and isPlayerSoldier then
					if gateOn.v then
						sampSendChat("/do Камеры наблюдения автоматически распознали лицо "..(lady.v and 'девушки' or 'мужчины')..".") 
						wait(1000)
						sampSendChat("/do После распознания сработали автоматические ворота.")
						wait(150)
					end
					sampSendChat("/gate")
				end
				return
			elseif k == 3 then -- открываем финд
				ex_find()
				return
			elseif k == 4 then -- клавиша локкара
				if interior ~= 0 then
					sampAddChatMessage("[Army Assistant]{FFFFFF} Вы находитесь в интерьере, команда недоступна.", 0x046D63)
				else
					if lockCar.v then
						sampSendChat("/me достав ключ из кармана, "..(lady.v and 'нажала' or 'нажал').." кнопку [Открыть/Закрыть]") 
						wait(150)
					end
					sampSendChat("/lock 1")
				end
				return
			elseif k == 5 then -- вставляем в чат "/sms " и номер человека, который нам последний писал
				if lastnumberon ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberon.." ")
				else
					sampAddChatMessage("[Army Assistant]{FFFFFF} Вы ранее не получали входящих сообщений.", 0x046D63)
				end
				return
			elseif k == 6 then -- вставляем в чат "/sms " и номер человека, которому последний раз писали
				if lastnumberfor ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberfor.." ")
				else
					sampAddChatMessage("[Army Assistant]{FFFFFF} Вы ранее не отправляли СМС сообщений.", 0x046D63)
				end
				return
			elseif k == 7 then -- делаем реконнект
				reconnect()
				return
			elseif k == 8 then -- включаем/выключаем автрострой 
				--[[if isPlayerSoldier then
					state = not state
					names = {}
					SecNames = {}
					SecNames2 = {}
					namID = {}
					secID = {}
					sec2ID = {}
				end]]--
				return
			elseif k == 9 then -- отправляем коорды
				if isPlayerSoldier then
					if cX ~= nil and cY ~= nil and cZ ~= nil then
						locationPos()
						bcX = math.ceil(cX + 3000)
						bcY = math.ceil(cY + 3000)
						bcZ = math.ceil(cZ)
						while bcZ < 1 do bcZ = bcZ + 1 end
						sampSendChat('/f [P.E.S.]: Передаю координаты: '..BOL..'! N'..bcX..'E'..bcY..'Z'..bcZ..'!') 
					end
				end
				return
			elseif k == 10 then -- принимаем коорды
				if isPlayerSoldier then
					sampAddChatMessage("+", -1)
					if x1 ~= nil and y1 ~= nil then
						if doesPickupExist(pickup1) or doesPickupExist(pickup1a) or doesBlipExist(marker1) then removePickup(pickup1) removePickup(pickup1a) removeBlip(marker1) end
						sampProcessChatInput('/f Координаты принял. Расстояние до вас: '..math.ceil(getDistanceBetweenCoords2d(x1, y1, cX, cY))..' м.')
						result, pickup1 = createPickup(19605, 19, x1, y1, z1)
						result, pickup1a = createPickup(19605, 14, x1, y1, z1)
						marker1 = addSpriteBlipForCoord(x1, y1, z1, 56)
						x1 = nil
						y1 = nil
						z1 = nil
						lastcall = nil
					end
				end
				return
			elseif k == 11 then -- включаем/выключаем vkint
				workpause = not workpause
				if workpause then
					WorkInBackground(true)
					sampTextdrawCreate(102, "FuckPe4enka", 550, 435)
				else 
					WorkInBackground(false)
					sampTextdrawDelete(102)
				end
				return
			elseif k == 12 then -- удаляем маркер/таргет
				ClearBlip()
				return
			elseif k == 13 then -- открываем меню
				mainmenu()
				return
			end
		end
	end

	for i, p in pairs(mass_bind) do -- тут регистрируем биндер на клавиши.
		if sKeys == tostring(table.concat(p.v, " ")) then
			rcmd(nil, p.text, p.delay)		
		end
	end
end

function calc(m) -- "калькулятор", который так и не нашел применения в скрипте, но функция все же тут есть
    local func = load('return '..tostring(m))
    local a = select(2, pcall(func))
    return type(a) == 'number' and a or nil
end

function WorkInBackground(work) -- работа в свернутом imringa'a
    local memory = require 'memory'
	if work then -- on
        memory.setuint8(7634870, 1) 
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
	else -- off
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
    end 
end

function WriteLog(text, path, file) -- функция записи текст в файл, используется для чатлога
	if not doesDirectoryExist(getWorkingDirectory()..'\\'..path..'\\') then
		createDirectory(getWorkingDirectory()..'\\'..path..'\\')
	end
	local file = io.open(getWorkingDirectory()..'\\'..path..'\\'..file..'.txt', 'a+')
	file:write(text..'\n')
	file:flush()
	file:close()
end

-- function getMessage(params) -- функция получения сообщений из ВК
-- 	lua_thread.create(function()
-- 		if token ~= 1 then -- проверка на получение токена
-- 			print("getMessage() activated")
-- 			local timestamp = 0 -- это нам нужно для сверки времени, чтобы не флудить последним сообщением
-- 			local ggvp = 0 -- это нужно, чтобы при запуске скрипта в чат не отправляло последнее сообщение из диалога
-- 			local vmmsgg = "https://api.vk.com/method/messages.getHistory?count=1&user_id="..tostring(params).."&group_id=193828252&&access_token="..tostring(token).."&v=5.80" -- сам запрос

-- 			while true do -- вжариваем бесконечный цикл
-- 				if remotev.v and workpause then -- если включен удаленный режим + активен VK-Int
-- 					async_http_request("GET", vmmsgg, nil, -- гоняем асинхронный запрос
-- 					function(response) -- если запрос прошел, начинаем колдовать
-- 						local vk_decode_msg = decodeJson(response.text) -- декодируем ответ ВК
-- 						if vk_decode_msg.response ~= nil then
-- 							if vk_decode_msg.response.items[1].out == 0 then -- проверяем, является ли последнее сообщение отправленное нами, а не сообществом, но это не точно
-- 								if timestamp ~= vk_decode_msg.response.items[1].date then -- сверяем время, чтобы не флудило последним сообщением
-- 									vk_decode_msg.response.items[1].text = vk_decode_msg.response.items[1].text:gsub("\\","") -- чистим текст сообщения от херни
-- 									if ggvp ~= 0 then -- собсна если это первое сообщение, то игнорим его, ибо иначе - при запуске будет выбивать последнее сообщение с диалога
-- 										if vk_decode_msg.response.items[1].text:match("/r.*") or vk_decode_msg.response.items[1].text:find("/f.*") or vk_decode_msg.response.items[1].text:match("/sms.*") or vk_decode_msg.response.items[1].text:match("/g .*") then -- чекаем на содержимое сообщения, допускаем только данные команды
-- 											sampProcessChatInput(u8:decode(vk_decode_msg.response.items[1].text)) -- отправляем команду, если все хорошо
-- 										else
-- 											vkmessage(tonumber(vkid2), "Отправлять сообщения можно только в /r, /f, /rn, /fn, /sms, /g чаты.") -- отсылаем ответ, и говорим, чтобы сосал писос
-- 										end
-- 									else
-- 										vkmessage(tonumber(vkid2), "Вы активировали удаленный режим. Чтобы начать передачу команд - введите необходимое сообщение еще раз. Активация работает до перезагрузки скрипта в игре.") -- отсылаем ответ, чтобы чел не тупил, мол почему не сработало
-- 										ggvp = 1 -- чтобы закрыть условие и начать принимать сообщения с ВК.
-- 									end
-- 									timestamp = vk_decode_msg.response.items[1].date -- устанавливаем время последнего сообщения чтобы не флудило
-- 								end
-- 							end
-- 						else
-- 							printStringNow("~B~VK is ~R~not available", 4000)
-- 							return false
-- 						end
-- 					end,
-- 					function(err)
-- 						return false
-- 					end)
-- 				end
-- 				wait(1000)
-- 			end
-- 		end
-- 	end)
-- end

-- function vkmessage(id, msg) -- функция отправки сообщений в ВК, и никакого JSONа хы
-- 	local https = require('ssl.https')
-- 	if token ~= 1 then	-- проверяем на наличие токена
-- 		local msg = msg:gsub(" ", "%%20")
-- 		if type(id) == 'number' then -- если айдишник указан цифрами, то один запрос
-- 			gurl = "https://api.vk.com/method/messages.send?user_id="..id.."&message="..u8(msg).."&access_token="..token.."&v=5.85&random_id="..math.random(956, 3412)
-- 		end
-- 		local zapros = https.request(gurl)
-- 		if zapros ~= nil then
-- 			local vk_decode_msg = decodeJson(zapros) -- ответ принимаем и декодируем JSON
-- 			if vk_decode_msg.response == nil then -- если есть "параметр", или как это назвать, response, то он значит, что отправлено, если его нет - выбьет ошибку
-- 				sampAddChatMessage("VK Server: {BEBEBE}"..tostring(vk_decode_msg.error.error_msg).."(API-Code: "..tostring(vk_decode_msg.error.error_code)..").", 0xFF6347) -- выводим сообщение в чат с ответом API
-- 			end
-- 		else
-- 			print("Error with vkmessage().")
-- 		end
-- 	end
-- end


-- function secure_vk()
-- 	local Lockbox = require("lockbox")
-- 	Lockbox.ALLOW_INSECURE = true;
-- 	local nu2aFsdGhua = 'RJ6WKXsxmhRcsJpTNCcaNM6qbSR8tWMJptmzUMHjhaK4pRkhJUJgMZFR7nf4S7cpaduX6Ydmgn4BbpTmHYvpUgpVZ4nJuTnTkJvhWnTUQxqCGmLpWjfZACLHAZDnNNsrh5FkPdpK5tUF4XHDdVkWYRtEDbqjLAGM2Mb8hKUVDZMhhPr8JpT9AbEqTqAArX4eKGETwa7Lrw9Z3rJn6rrfuNZzy4dRXQUyrxvJXSZFtBDj9ZEfYyDXgSVkBG7k5M3DgavDs3aECp3R8rrNZHVdnST4fMZkd4w8eWm8FvKEgU9B4ZXFPyBLPwLSch6yMCrftnchnCjjFT8UDtnwwdZPH2FATFxaWww5xQpw6DFKxtZnSPCesUYAwdXLUxFZfht99nVztSXgmrXASQj4edenwEuBe4fCWdfw4tawZvr7L26QkSKBu6tbwumk9S7TLDpcQ8Xe39RkVsa84enK8XV8cztKj3wvgC6aWqjkQTGzeg4tHWcVCrghxB5yg4XnD62NqjhazKjVRdgeC3Lt2cSbvjY3ms6jP2PW589jSfYq8MXYKnjV6cNkLUsBWhrGRGj7rjfT8ArXFs46CwzTWqFYn7X95ETfAWyCt5RWXzJpSJTTbjmPHdvZqNGfc9NSJNFYcHnQw7cEsmPavdMestarKapvjj6bU9LstZqcfaJcxcvZrP'
-- 	local uib1iGbuTgty = 'NuWh9jcq3Smpm4VQTdBz84JScemxLHn7Dt3LyYMAyeLDqGKRWnRn6BLEHUeXq2T8gFQnCMkBbCXVQugk6L3dhzMCtKgy937Sp3cwqmVBtzFa3Adw5cBHhSjdZBpUZgaRPUEA8eA2gStYF4AqxqfbChNqbbmZXFQh4HGWVQsFBrVBcsKCgjuFtbNgpnVsMHeydmz5krzBhyQL2aewzpDCgcMy2HXNEepJDysvjNbvWFm4qwntybgcEQGGQJktFuZWTQRy36PfNhKjDdCNNxzwsRepRXt5gPsWp7UTp5ZayxDwX6XAREFqXnQJFfyx2fqEkQPGerMsRyjxFfrnWXPu4eLG679KzzZUXwNkfR8qA5RpNPnGUTdCLyh57QgxNYupygJ7HfrDv5zQhuKzfquCDHFv3WxsTWPWQcfHSM2krRFXCJE7yskxTVB9m9D22U86SAYaYp8EVd6gZrABXW69emnn5v5NR22hNCPB9z7qT7Keyb7CQhRWte9QKLasx7jm3DXMSDNDe2w8yGPc2BLBcLrCkyJJqJydSqxx6CKTyJXYvwJyEU7tJNZgPh8k4mp64zuHrfCxxxbTCJvtwzvLcWDKtj9VZdKbwk5EEEE2pckHs3CCABdH8xDnfQebTHnG4ZjTPZ4gfC9PLhHZTCNjF2VpQeJWqq8aMqxcSdvdT3zhFAWJJmDkcegh3Jxgxf2bqbcWgrUgZPhH4vBe2ZsCKCYMHhXCRPR2beTgM5hpMcghMChU6n4KyE3CU23PLTabZRPHJTzKRdXBa7zFA5pD2nUsyMb9eQmCsEX9f'
-- 	local a9suHasVdbib = 'QY22N2hYVgwbtnt4y3K7QfGuaHfJgM3ARsrDtK3eJKTuQjR5jPBqY4n3HmURbJSVsCJVCCmbVtTmPtW4gCbZpnBCq5RgR5fqJs6wyA7EZw7BZS68W4JvwDeDTP3EzAfKs7NgGjhfBjnbH2F8kCy9mnKYT3dBSJYbqkLdChag9QqaCZuKqPNLQva9ENE2ZsFEDWjn2RULT35ymSE2NEhb9QSYpBQM84QQWHjKdvwabExCeEpMM9Jtu3CK4VNkQhvzK62vNJyJrYX6v6tN7XbZpBZx4zY9mGDNq8dLcC98H9jtjTzUTsQjADTYxCEvBbKdj9JBGMXnQLnFgnHKtkA9Kj2nS9MH8n5ZQpJkRaCT8Bwqq59UWQJ2rZN9UEjmPkA8zFaDAbBBxZMVMXpXym2jhQmyTtBUvLs7waSJL7LNT72cMZHWRZ5gtfkYWHNxCCwmrVYrkeDT2stHEazHB8rmBK8TgU8trEtux6bTwYJA3XuvcURptu72VjrTpqT5LjVczYjeJPd73PNJR7GUzwzqDsQMbvgqmXPVZnmxJSLj5nNUm'
-- 	local r98xXhkBxJ = 'uUtNeRXM8CHe7vfhnKZsFwdUR44W5M4mSfrVNt7BMbV3ZQ9ZBeb5yfCNWRkzHFYzpkvug7fKZt2Dk7dRWgMGTXPUGqwD7ABxyjJ2BWSjLSRUQmssqfv6qu7jxLre8YP6SAMMncK4ebknvYpKTbbXb5UQbysFR5AkErPdSE3Xaa8Ge9ZNC7jQDJHuE44YYkvxY5bC6LaprGgScMRKRts34n7VZQ2f6ukPWubYDuxfVWdmn9pGM4zf444T3KxQ2pf7daU8MSyQLf5LWNJdtChnvWTzyKdq5wfE9RF2U5KfyVSrKPYUf7K4GxCegBrWgubErDnyUs6GVVBM7HJexgtpJtJCM3ddMANGsw3x8QZ3j4bnFmntsUHRh8ZFDTYQrPFUcnsqKHEKCFUSvZyuzXT5ThAcXuRPjaKNaxsxSmunypZNZhRun8QydKeLrWxAJVAsT8W7qKRfrTc876yTURvCgVDwfGzz3kd2Mvn6L3Z5MTs58LWqzUtLyJkLkLUrdA8r'
-- 	local J9nCgPFBKw = 'uBUP9tfEDQ6wu2ksheUPrHAuceQtCNsxASVWey2PzZxDy5SyD5FVpQkJeFVuyb5KShwpvhXh6zQpybXfRewnBGrTFYXuU9zXjAgsMb8LcPsT2VMS3ghQwkPdyaxkfkeAMGdkNetvEZaDbTJpM2DPSL7nCs5BvmbdPLxUH2tGVr495tgSZK95sJmM8ez75wANDZUsTQyRcaE92P3Ln7XJaFj6TrskuREtm2cpjwXZLkftp9DGsABUxZSfpsJmaxwx6D3Kjs758gtjVe74k5QM2ZETAkWaDsQAWw29qRacAFrrUPmU7sMVE8hCKeWX5yBbNDC9vDmFUP5qzBSrZpsgrREwaVSPEN64S2FHC8ArXNAvDbxkrUvLjbRMxuhakB27CQyU7nyHYjmN58zg4g4SK7s7R8n97CHRHLT7sjnLeSJ9Pa62356YnJBpdFQnPwVerjqxMuChSvDc6GxuDGYJFrxExAL6TRnReTeM9fZnmyQS8ybYBs4ed78vsbuKFcpX'
-- 	local b6RxeCRBc7 = 'wd3T2Fk2eXK4WZ4QaGhJfBFe8D3p6t5nuFPkqtb8WCvgBuTWnSE3aXsPcGhKQPWYDAPx8dHDuv3SCyGqacf7yVcvGmFZ62mPvuHbqHEGHEwa3HhPbZf8vLPD9apVjYQQRZWcWh6Q8jfqm7duUEZy9834YQ3zM2yZLG7ca2USxN6WKj5Q2n6m8vy4sACxVBzfze3hQuusnMvzsbGb4ryg9f7UsNHCk2BCphn3fxvgLXjBtGdbdbgjX7tckV52eFGAJkkaAx8ftA7gHw7RWd4GuSEdB2g8kYcF6m224WewGajS4TMSc5dMwYa6tPn3bkT9Xj7RWfxvYMLHsmdYpetP7MZHxhudjr8g3AxvGhfM3rmDqgaU7Nh7BgD3YVcACTpHU58yT3J9rABmdMJXz754gHF2K9tLL3QVwVnzDpNt3VMuYeaHDBFcHKDRhwKVxcmwNGZbEpPsDyPAQRR84yskt99edZPxE68sLqVDZCNZR83cq6F9vFWacakSrffKZMfa'
	
-- 	local Stream = require("lockbox.util.stream");
-- 	local hmac = require("lockbox.mac.hmac")();
-- 	local SHA256 = require("lockbox.digest.sha2_256");
	
-- 	hmac.setBlockSize(64)
-- 	hmac.setDigest(SHA256)
-- 	hmac.setKey(Stream.toArray(Stream.fromString(nu2aFsdGhua..uib1iGbuTgty..a9suHasVdbib)))
	
-- 	hmac.init()
-- 	hmac.update(Stream.fromString("Error in secure_vk(): token error"))
-- 	hmac.finish()

-- 	local anybody = {}
-- 	anybody.data = "gasaiIdiNahuyAhah=lVl4wFD#YxTRKCAMV30Zgkkxn?EP10iNEC22VOh}|NBhnpim1O6Cr|JkYjZMJ@hs~hRF}qCxY3FDeR9t?oqFLaa7R2rj77~$EeFlTX1h9r1O*LEXMyHEQu69qcVLR2pA*%ap{Oef#g6CL4jtj@~|~~yUF~4q~WOG~S|UgEeZ?G&k=Dnd{B%#xBW|JB{uipQ~ZRRLaufCB@9WpZ~d5b$dYob5Ahv#1kkpCdtY~kzVPx3gNiY#Ju82*s%8Vhy5R2P%CJ$VXnRvcJxzciBHCVZ8I$O2P@WuKKofyyquk2zB6*vK&key1=adKTu7!qjQXz#9SSnQ$73fbfKT__4E!Xyg2dgfb6reMz^sgAtm59EXvELwF9?h#u^4S#fN^-Yssdj=Wuv4!V=AH7yzg9qN@msb^$=sqADNFJjW3Tv=bB-HUQETUjGcbh-DbrtkXyP9*EVk&cy968ZH84%_Fz2@BQXqcp=f^vLn6h=%Svu?Wrk%jF43aRMN8J^tMzR2Uz5%PU*%kw#$TjNjFm^ha4bX-uynG?#$9mbtk#JXecbh_8F+wtHh@9TMrKgGM^P#^4sTbt9at&vk=P$mL8BPGrWrWJC_WA-&d-TJQ@+tA4sn?S?!G?kskQ!TjjL%4jZJ%vq2^EhAR=Y#=kz&?$?pQ5MJgMgx+L8URf#yhj&QL55UV^39vvanmwY=NQbzM37s*DMceZ9EwH3wM_6q^*@fQQ63SA6q+?SdqDmUw4&sx+fEqF3mWmvKABK=SV=d&9^*tUhbden6BjFm!pGZ&Mv@BLwxzrqVUzmUNQb7zf9^6NLp*YQKFTmmX%y=FR8RUJ=?tYjff2E#yS?+@3y^@$eFt7qEC3p&XEfcA#V9TJ#3FU3nM6Kw3jYt8_**CwEMDk?NkcNn34h4?gerfR*Nx9RrbqEYf3VFe6_+D+!fES_4bEV^uw_4VmNT+7_B2y_65W9gPWrJ8QgpZQH%GEEJHYem$?r=u3aEdX!m%ZK9eF3!&CrUTbNRjDDVrwXEU3ZRDtWju6vqf-=f-LtqkzJkRdm*+RkC_YzaS?8N9bH2TMx3DZyf%Q$xcsT6!TycKMwcq*XR7D$n_*j&Zq6_D4FBPQr7RSd8kB5br4t69hC^%3@$YPpt?hp@QN3C&WbnN2XRUgMxPg=8F7-42=LTE%LVv=UyV^b5V$^PhvFQa&_F9%$5Rjs9G8&%2!VcmYs5kW_zykGaqJ?RuyxuTpyA%EVqKWj^MV+zn56^eNdMsF^BKJtemYr6d73%c4F5$KV7VWywCpfvJ#HvDJv6dRL8X5WHDZ_Wk%$XXZJn-y%r6Tb_HcAcU7FP74GGbbRTHRg9LtwqYV^V%gTE9Sa-Dv2W7wp9DaKmJzBGgR$uDL6Jggj=sE_3%?C7#SJX27V4gfB^WRpqgdh?KG7Lyx&s#8QW4RRr_zS^GJQP=Tb%jhtPw43x87Fp-RMkDaJ2UQYH%HCa&$8-_hyh8&bYCBzkzRe8q7cRzDw?Uh=tzeDXcMpKbZsz8&gRjXNa_$VdP@!SgZ&g*ddkME%$x+t?pJ%-zK6q%jd@k5B6AP4V78HW#rDv^*+3WpzWKcKUu4EJxWXcwu-AHYj3T3EEN&DpP$bYSGbPnt!qVrC?D848NrDdB#D#jnF&@L*Tba-MZ^Cn6W34fPmgZg%waCStTdCJg&gFW*gDsLF_*G@+n&^&$_7qs98PmbwcPcsY2DcPe&&5t3P7jEcX33%-?Byjsc_RN@HZx+6%V&Ey$G9JhxV-vbDfw5aYxH6^X+wv59$LhgdgzU4GZRbDKFttBtTSt8f4-4QGG6V6j2TpS!6uGSD?tb&3hkXh$ffC+Y-uad4MmQN**p--gxKsA!N-$Gsdx#MmE?W9=N%%8Tcj6fTJ3*Br#ETQwJ2A!Y&G*rgPwZfgp5-VKK?wPLakehrtL^9rRjXMS4kXwLyB9sSkbz2H6pGR@Cr!+4ML^32*y=EHh6gtq!ghmru*Y+JbDA!NgcP2+gHfPEZygBTdzq2QeVbgc!hnLjbnP426dYx_Y-B&@Pnge+xc=mSGeNN+G4QCD#$p*QS7gj_uLFYQyN_NUmu544&f6&sJK-b!T&jyS$M%A2v%fBLhBG=96tuvSVHgu@jzJpYYBWHXRuw@qb#!SRqxuB^rc9?E9PgbNUnyE&#Nx!rNzyc&Wb5!2MHam#3@#3!&U3vr57q5@Zs*^=T4u^&Ze!t3UyGxWd5DEYqujPGanMcfc?aChC&eQB**Th$_4$5?p=GDe!YzuWwS-*aT9yW^ZWs&-mcpATTnzCy2gJX-S5?w6sb*RaeWwaKG_KzdYR34V+Tq!b-CM?N^7A9jCS^ynH$!QE7LL&mks="..en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(en(hmac.asHex())))))))))))))))))))))))))).."&p=zArchzMDc&^&key2=j^rx-f*tu7VDXnAa=-z=d7vvt?kpNz7XrX7v@?_6v7QXwJFMw9jneTL*!8*K-gN8^d5Fg-f&Qrjn$fX_*kSE3C!YK2tHkd7dR2y_cSPHaSPzz$fU65JW6p2-gnSH27kVx#2^Bk!CdSnVc6X2?_PJ794_q=FyzG7f3K^bFsXv!%7ZVPEM@r3e3CDLvhh9LEcv_Pzk63WY4MjMf*zNu*ET!JN6f?bj2y@ktKzNFcYHZbv?FyfZh=e2kD=z9NBpD-Nz9AJfgdwy7-b8699jqxN6YCd^w*j$%LnydSJ@KDk86nYfbqtr*7CDW@TE!HG-dANH4zy_jJDV4R_@r#-MT^ppJnFErBGjR+YL&Cqw7tnkrELXg5U-2ZY!8YV2*4KUCB8bMkqb$_76BT+M6BamLM^2XwZPF2%azhYhLctXuCQ3v?J7f$a9U*L8vDccLX9A!2frqphFc=*q4hAw78K9N*-cRX_K2ER$K^?ECQhU=c8S@R@PQMfn6jFZ=W^Cp^7!CeEK!gheZ8u-GLz_*!wX2y#CGJ8ePVBUZV5y3nF-JpBR-q4u$Kw+@_zsZfe!+^TBK*5ZQLq4+DSG?bFAzkpZhT=U%LL2FeampD=*X45MjjgQmeqJ6JbY=bkHQNG-^EC6^AL_xQ+mzm-mSa7M6H8EcmLr@hSrKEsHa7%9p%A!utEgkp22=46AFh#6@b_5%6MRa$VAQJ4G$=*XW6s&6$*qPS+q$r9RZn5XDsmJ#_qM3W%JX7J@qKLve%J?mFf=hT=StWk58As*aLVr6Lb?eWLvbs&?nw?T2PPvxJP$^TU8*h5!JEA*zvTEwLN^ehQ8waqWvrv3$D%urXXPt3X#h@*RCK2cFJnE6JdHd@82Fj+Ajyf^QXCB9pawwqcB%Q-ec+p@38_yHBE7*!qnrSY9c?wx75%P$PgQD&BPGs8NCS$kXyD5g46E3dpp75kuG97D#6eqH$Am9AJbS@CF*k%5rSUADtF$PKGG6gWY?MMN+emcQ_W^wpgTXx*d_#G?4XquMMJf9nh4#?w2^xhnswtLHd*U%W#e8!TC6gL$5G?X+nbZEyM7XKk4PxEf54GU_V+TCWFJPX%Kj!!-6?VVAX*ww?+ED^8JAwC?ZedVJzAZPG&PZs%59CsW^ajFX-L-TDS%UwfRbKq29bnDq?ah&+UBpgP5k$$5B6P9*pgutV#zS^XSZSCV#3r5w?SdRYk@Rcc#Cnnku%We?!PWE5nzCzWA%$7XT79Vqkt#zfuq8v*NwPnR^dt!&C?@*6s&RpPRtp?MWQVHd!X+5nh2uyG%-FvV_9Kq-4F2?GER9#w^WHQzfb4GkGrhbgjN3#^R+%-y%e6wktg8uwHb$L@J_r#L2Jn=$VMB#sDdFfMY&Dztn=YenvQMSy*P&hG89NN5Ta9sn2Gga-XT?bJ5^hcKC&pBKwAjh*n^LM+XyH3^DmD#kSucWYe@xX#QUNcT&tY^SB2=-p+-%Upxr*_$YbxG_cyFgRWH__Rc5PL6!7_G$WWP59e!__E9Hb64vLLLjJa^b!u*nEgcQ9rKf3vmL9D9qVWtbX3^m!*6##fD6bTTgjtcYXL2%FFTfRAy%rbGXAJxCW+ce9uUGNedZdJx-ef!9#Xw#dZhE&Bnne7gyVsvj-@jKY+D?*qX-88Fvj_eW6X!!t#p$Xt!Y&FPNe452^Gnm!B%KwARRGy4cde?Q8$6#wCm^HSAKs6@7A+stfp-99YhB&9w%72gUU7H*#$3ZfvVnk883Xs@j$Rm2k-KXJzP5fXG^KPJr=KSE4LLkJgzNTv5M#+#h_Y9u=LL=HC2DVuYv%&L7uy=t+6sCL%*af&V*WqvC!D-kufNcUtVmhG?BJty#bLQXc^r^KBgP_V2y_2GrxWr_fpbUWt^&VTgJukAVLmFZZwS#xt&K%K$KuLMPWkavf#+S&hW4DErFbaBeG*Bg*8sd9STvUEWFH+S8!2@Xm*8%PFXN@Tm^+t&n-mFTTTjcUQ_nKkn&t?Ljg=fbr^fyDDSh5!ej?-pwc*TGW%5hVtPx&C368s9GRe7L?kzJzxV+B4HRL55BLT2mkf="
-- 	anybody.headers = {
-- 		['content-type']='application/x-www-form-urlencoded'
-- 	}
-- 	async_http_request("POST", "https://frank09.000webhostapp.com/YVJZsM9458H4cvqHyGgyp992zETrHjhf9vMq2jNPGzFWYX4XayYMgB5ETXVbEWq8pkW5fqvtw3RdNaeHMMs3zX4769bSpHfrqkgg.php", anybody,
-- 	function(response) -- вызовется при успешном выполнении и получении ответа
-- 		if response.text:find("yJqeuQNKFyKrzzQpfp8Aqjks9ERV") then
-- 			token = tostring(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(dc(all_trim(response.text:match("JaRmyJqeuQNKFyKrzzQpfp8Aqjks9ERVkrmrufwV(.*)NDjyS53nQrT4hayUU4Y37"))))))))))))))))))))))))
-- 		else
-- 			token = 1
-- 			sampAddChatMessage("Server: {BEBEBE}Error with VK Secure, correction mode activated.", 0xFF6347)
-- 		end
-- 	end,
-- 	function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
-- 		token = 1
-- 		sampAddChatMessage("Server: {BEBEBE}Error with VK Secure, correction mode activated.", 0xFF6347)
-- 	end)
-- end

-- function checkVK(params) -- функция проверки игрока на наличие в подписоте к группе ВК
-- 	if developMode >= 1 then
-- 		print("Correction mode: Disabled function #1") 
-- 	else
-- 		if params:find(".*") then		
-- 			if params ~= nil and params ~= 0 and params ~= 1 and params ~= 2 then
-- 				ggurl = "https://api.vk.com/method/groups.isMember?group_id=168899283&user_id="..tostring(params).."&extended=0&access_token="..tostring(token).."&v=5.80"
				
-- 				local zapros = https.request(ggurl)
-- 				if zapros == nil then
-- 					print("CheckVK error.")
-- 				elseif zapros:match("{\"response\":1}") then
-- 					print("VK checking success, account is in a group.")
-- 					return true
-- 				else
-- 					sampAddChatMessage("[VK Check]: {BEBEBE}Зарегистрированный аккаунт не найден в сообществе разработки.", 0xFF6347)
-- 					print("VK checking error, account '"..params.."' not found")
-- 					reloadScript = true
-- 					thisScript():unload()
-- 				end
-- 			else
-- 				sampAddChatMessage("[Army Assistant]{FFFFFF} Верификация статуса привязки на данный момент невозможна.", 0x046D63)
-- 				print("CheckVK params 0 or nil")
-- 				reloadScript = true
-- 				thisScript():unload()
-- 			end
-- 		end
-- 	end
-- end


-- Шифровалка Base64
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
function en(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function dc(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function tags(args) -- функция с тэгами скрипта

	args = args:gsub("{params}", tostring(cmdparams))
	args = args:gsub("{paramNickByID}", tostring(sampGetPlayerNickname(cmdparams)))
	args = args:gsub("{paramFullNameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub("_", " ")))
	args = args:gsub("{paramNameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub("_.*", "")))
	args = args:gsub("{paramSurnameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub(".*_", "")))

	args = args:gsub("{mynick}", tostring(userNick))
	args = args:gsub("{myid}", tostring(myID))
	args = args:gsub("{myhp}", tostring(healNew))
	args = args:gsub("{myrang}", tostring(rang))
	args = args:gsub("{myarm}", tostring(armourNew))
	args = args:gsub("{base}", tostring(ZoneText))
	args = args:gsub("{arm}", tostring(fraction))
	args = args:gsub("{city}", tostring(playerCity))
	args = args:gsub("{org}", tostring(org))
	args = args:gsub("{mtag}", tostring(mtag))
	args = args:gsub("{rtag}", tostring(u8:decode(rtag.v)))
	args = args:gsub("{kvadrat}", tostring(locationPos()))
	args = args:gsub("{steam}", tostring(u8:decode(spOtr.v)))

	args = args:gsub("{time}", string.format(os.date('%H:%M:%S', moscow_time)))
	args = args:gsub("{myfname}", tostring(nickName))
	args = args:gsub("{myname}", tostring(userNick:gsub("_.*", "")))
	args = args:gsub("{mysurname}", tostring(userNick:gsub(".*_", "")))
	args = args:gsub("{zone}", tostring(ZoneInGame))
	args = args:gsub("{fid}", tostring(lastfradioID))
	args = args:gsub("{rid}", tostring(lastrradioID))
	args = args:gsub("{ridrang}", tostring(lastrradiozv))
	args = args:gsub("{fidrang}", tostring(lastfradiozv))
	args = args:gsub("{ridnick}", tostring(sampGetPlayerNickname(lastrradioID)))
	args = args:gsub("{fidnick}", tostring(sampGetPlayerNickname(lastfradioID)))
	args = args:gsub("{ridfname}", tostring(sampGetPlayerNickname(lastrradioID):gsub("_", " ")))
	args = args:gsub("{fidfname}", tostring(sampGetPlayerNickname(lastfradioID):gsub("_", " ")))
	args = args:gsub("{ridname}", tostring(sampGetPlayerNickname(lastrradioID):gsub("_.*", " ")))
	args = args:gsub("{fidname}", tostring(sampGetPlayerNickname(lastfradioID):gsub("_.*", " ")))
	args = args:gsub("{ridsurname}", tostring(sampGetPlayerNickname(lastrradioID):gsub(".*_", " ")))
	args = args:gsub("{fidsurname}", tostring(sampGetPlayerNickname(lastfradioID):gsub(".*_", " ")))

	if newmark ~= nil then
		args = args:gsub("{targetfname}", tostring(sampGetPlayerNickname(blipID):gsub("_", " ")))
		args = args:gsub("{targetname}", tostring(sampGetPlayerNickname(blipID):gsub("_.*", "")))
		args = args:gsub("{targetsurname}", tostring(sampGetPlayerNickname(blipID):gsub(".*_", "")))
		args = args:gsub("{targetnick}", tostring(sampGetPlayerNickname(blipID)))
		args = args:gsub("{tID}", tostring(blipID))
	end
	return args
end

function mainmenu() -- функция открытия основного меню скрипта
	if not win_state['player'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v then
		if win_state['settings'].v then
			win_state['settings'].v = not win_state['settings'].v
		elseif win_state['leaders'].v then
			win_state['leaders'].v = not win_state['leaders'].v
		elseif win_state['about'].v then
			win_state['about'].v = not win_state['about'].v
		elseif win_state['help'].v then
			win_state['help'].v = not win_state['help'].v
		elseif win_state['info'].v then
			win_state['info'].v = not win_state['info'].v
		elseif menu_spur.v then
			menu_spur.v = not menu_spur.v
		end
		win_state['main'].v = not win_state['main'].v

		offscript = 0
		selected = 1
		selected2 = 1
		showSet = 1
		leadSet = 1
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	print("Начинаем подгрузку скрипта и его составляющих")
	sampAddChatMessage("[Army Assistant] {FFFFFF}Скрипт подгружен в игру, версия: {00C2BB}"..thisScript().version.."{ffffff}, начинаем инициализацию.", 0x046D63)

	-- if doesFileExist(getWorkingDirectory().."\\MoD-Helper\\files\\regst.data") then secure_vk() end
	files_add() -- загрузка файлов и подгрузка текстур
	
	mlogo = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\img.png')
	errorPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\errorPic.png')
	classifiedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\classified.png')
	pentagonPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\pentagon.png')
	accessDeniedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\access_denied.png')
	helper_stefani = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png')
	
	

	print("Создаем файл черного списка")
	if not doesFileExist(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") then 
		local blk = assert(io.open(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt", 'a'))
		blk:write()
		blk:close()
	end

	print("Подгружаем настройки скрипта")
	update() -- запуск обновлений
	while not UpdateNahuy do wait(0) end -- пока не проверит обновления тормозим работу
	load_settings() -- загрузка настроек
	
	repeat wait(10) until sampIsLocalPlayerSpawned()
	print("Проверяем подключаемый сервер")
	print(sampGetCurrentServerName())
	if sampGetCurrentServerName():find("Gold") then
		gameServer = "Gold"
		srv = 1
	elseif sampGetCurrentServerName():find("Test22")  then -- проверяем подключенный сервер
		gameServer = "Test22"
		srv = 2
	elseif sampGetCurrentServerName():find("Test22")  then -- проверяем подключенный сервер
		gameServer = "Test22"
		srv = 3
	elseif sampGetCurrentServerName():find("Test22")  then -- проверяем подключенный сервер
		gameServer = "Test22"
		srv = 4
	--[[elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 3
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 4
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 5
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 6
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 7
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 8
	elseif sampGetCurrentServerAddress() == "gold.diamondrp.ru"  then -- проверяем подключенный сервер
		gameServer = "Gold"
		srv = 9]]--
		
	else
		print("Сервер не допущен, работа скрипта завершена")
		sampAddChatMessage("[Army Assistant]{FFFFFF} К сожалению, данный скрипт недоступен для работы на данном сервере.", 0x046D63)
		sampAddChatMessage("[Army Assistant]{FFFFFF} Свяжитесь с разработчиками, если хотите уточнить возможность решения данной проблемы.", 0x046D63)
		thisScript():unload()
		return
	end
	print("Проверка пройдена, сервер: "..tostring(gameServer))
	
	
	-- ожидаем спавн игрока
	
	print("Форматируем чекер ЧСа")
	format_file()
	
	-- определяем ник и ID локального игрока 
	print("Определяем ID и ник локального игрока")
	_, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
	userNick = sampGetPlayerNickname(myID)
	nickName = userNick:gsub('_', ' ')
	sampAddChatMessage("[Army Assistant]{FFFFFF} Внимание, активна {00C2BB}локальная{FFFFFF} версия, активация {00C2BB}/mod{FFFFFF}, разработчик: {00C2BB}Shifu Murano.", 0x046D63)
	sampAddChatMessage("[Army Assistant]{FFFFFF} Технический модератор в отставке и просто хороший человек - {00C2BB}Arina Borisova.", 0x046D63)

	print("Начинаем инициализацию биндера")
	if mass_bind ~= nil then
		print("Регистрируем команды бинда.")
		for k, p in ipairs(mass_bind) do
			if p.cmd ~= "-" then
				rcmd(p.cmd, p.text, p.delay)
				print("Зарегистрирована команда биндера: /"..p.cmd)
			end
		end
	else
		print("Критическая ошибка, выполняем откат binder.bind")
		mass_bind = {
			[1] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[2] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[3] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[4] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[5] = { cmd = "-", v = {}, text = "Any text", delay = 3 }
		}
		print("Откат выполнен.")

	end
	print("Регистрация клавиш бинда")
	for i, g in pairs(mass_bind) do
		rkeys.registerHotKey(g.v, true, onHotKey)
	end
	print("Инициализация биндера завершена")

	print("Начинаем инициализацию клавиш")
	if tBindList ~= nil then
		print("Регистрируем клавиши")
		for k, v in pairs(tBindList) do
			rkeys.registerHotKey(v.v, true, onHotKey)
		end
	else
		print("Критическая ошибка, выполняем откат клавиш")
		tBindList = { 
			[1] = { text = "Тайм", v = {} },
			[2] = { text = "/gate", v = {} },
			[3] = { text = "Сотрудники", v = {} },
			[4] = { text = "Carlock", v = {} },
			[5] = { text = "In SMS", v = {} },
			[6] = { text = "Out SMS", v = {} },
			[7] = { text = "Реконнект", v = {} },
			[8] = { text = "АвтоСтрой", v = {} },
			[9] = { text = "P.E.S. Help", v = {} },
			[10] = { text = "Принять P.E.S.", v = {} },
			[11] = { text = "Fuck Pe4enka.", v = {} },
			[12] = { text = "Снять маркер", v = {} },
			[13] = { text = "Меню скрипта", v = {} }
		}
		print("Откат выполнен.")
	end
	print("Инициализация клавиш завершена")


	-- Получение номера аккаунта игрока
	--[[print("Получаем номер аккаунта игрока ARP")
	ScriptUse = 3
	regAcc = true
	sampSendChat("/mn")
	while ScriptUse == 3 do wait(0) end
	if ScriptUse == 4 then -- в случае неудачного получения номера аккаунта
		print("Номер аккаунта не получен, работа завершена")
		reloadScript = true
		sampAddChatMessage("[Army Assistant]{FFFFFF} Прозошла ошибка при получении данных номера аккаунта.", 0x046D63)
		thisScript():unload()
		return
	elseif ScriptUse == 5 then
		print("Номер аккаунта был получен: "..tostring(playerAccoutNumber))
	end]]--

	-- registration()
	-- while not regStatus do wait(50) end

	-- if developMode == 2 then
	-- 	print("Correction Mode: Disabled function #2")
	-- 	token = 1
	-- else
	-- 	print("Ожидаем подтверждения VKID")
	-- 	while not gmsg do wait(100) end
	-- 	if vkinf ~= nil then print("Подтверждено, запускаем цикл") getMessage(vkinf) else print("Ошибка VK Int, получение сообщений невозможно.") end
	-- end
	
	-- while nasosal_rang == nil do wait(0) end
	print("Выполняем отправку информации о запуске скрипта")
	if userNick ~= "Shifu_Murano" then
		local utime = os.time(os.date('!*t'))
		local mtime = utime + 3 * 60 * 60
		local sendstat = {}
		sendstat.data = "srv="..tostring(srv).."&n="..tostring(userNick).."&num="..tostring(LocalSerial).."&arm="..tostring(arm).."&rang="..tostring(nasosal_rang).."&number="..tostring(playerAccoutNumber)
		sendstat.headers = { ['content-type']='application/x-www-form-urlencoded' }
		async_http_request('POST', 'https://frank09.000webhostapp.com/stats.php', sendstat, -- получение данных статистики с сервера
		function(response) -- вызовется при успешном выполнении и получении ответа
			print("Сбор статистики: "..response.text)
		end,
		function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
			print("Сбор статистики: "..err)
			return
		end)
	end

	local getColored = {}
	getColored.data = "srv="..tostring(srv)
	getColored.headers = { ['content-type']='application/x-www-form-urlencoded' }
	async_http_request('POST', 'https://frank09.000webhostapp.com/getColorUsers.php', getColored, -- получаем список пользователей скрипта по никам для окраса
	function(response) -- вызовется при успешном выполнении и получении ответа
		print("getColored: Done.")
		getServerColored = response.text -- задаем глобальную переменную
	end,
	function(err) -- вызовется при ошибке
		print("getColored: "..err)
		return
	end)

	inputHelpText = renderCreateFont("Arial", 10, FCR_BORDER + FCR_BOLD) -- шрифт для chatinfo
	lua_thread.create(showInputHelp)
	files, window_file = getFilesSpur() -- подгружаем шпоры
	
	print("Определяем скин персонажа")
	local playerSkin = getCharModel(PLAYER_PED)
	skinPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..playerSkin..'.png')
	
	print("Регистрация скриптовых команд началась")
	-- регистрация локальных команд/команды
	sampRegisterChatCommand("cc", ClearChat) -- очистка чата
	sampRegisterChatCommand("test", test) -- очистка чата
	sampRegisterChatCommand("rm", ClearBlip) -- удаление блипа
	sampRegisterChatCommand("drone", drone) -- дроны
	sampRegisterChatCommand("leave", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['leave'].v = not win_state['leave'].v end end) -- дроны
	sampRegisterChatCommand("reload", rel) -- перезагрузка скрипта
	sampRegisterChatCommand("where", cmd_where) -- команда чтобы запросить местоположение по ID
	sampRegisterChatCommand("r", rradio) -- Обработка /r с тегами
	sampRegisterChatCommand("f", fradio) -- Обработка /f с тегами
	sampRegisterChatCommand("rd", cmd_rd) -- доклады в /r чат
	sampRegisterChatCommand("fd", cmd_fd) -- доклады в /f чат
	sampRegisterChatCommand("liv", cmd_livby) -- запросить увольнение(офикам)
	sampRegisterChatCommand("uninv", cmd_uninvby) -- уволить по просьбе
	sampRegisterChatCommand("ok", cmd_ok) -- уволить по просьбе
	sampRegisterChatCommand("uninvite", ex_uninvite)
	sampRegisterChatCommand("uninviteoff", ex_uninviteoff)
	sampRegisterChatCommand("rang", ex_rang)
	sampRegisterChatCommand("changeskin", ex_skin)
	sampRegisterChatCommand("invite", ex_invite)
	sampRegisterChatCommand("mod", mainmenu)
	
	--sampRegisterChatCommand("base", function() if isPlayerSoldier then if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then selected3 = 1  win_state['base'].v = not win_state['base'].v end end end)
	sampRegisterChatCommand("upd", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['renew'].v = not win_state['renew'].v end end)
	print("Регистрация скриптовых команд завершена")
	
	
	if isLocalPlayerSoldier then -- если по стате игрок вояка, то включаем рандом сообщения в чат + инфу о людях из бд грузим
		random_messages()
	end
	
	-- используем bass.lua
	aaudio = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/ad.wav", 0, 0, 0) -- уведомление при включении скрипта
	bass.BASS_ChannelSetAttribute(aaudio, BASS_ATTRIB_VOL, 0.1)
	bass.BASS_ChannelPlay(aaudio, false)

	asms = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/sms.mp3", 0, 0, 0) -- sms звук
	bass.BASS_ChannelSetAttribute(asms, BASS_ATTRIB_VOL, 1.0)
	
	aerr = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/crash.mp3", 0, 0, 0) -- краш звук
	bass.BASS_ChannelSetAttribute(aerr, BASS_ATTRIB_VOL, 3.0)
	

	while token == 0 do wait(0) end
	if enableskin.v then changeSkin(-1, localskin.v) end -- установка визуал скина, если включено
	while true do
		wait(0)
		
		-- получаем время
		unix_time = os.time(os.date('!*t'))
		moscow_time = unix_time + timefix.v * 60 * 60

		if gametime.v ~= -1 then writeMemory(0xB70153, 1, gametime.v, true) end -- установка игрового времени
		if weather.v ~= -1 then writeMemory(0xC81320, 1, weather.v, true) end -- установка игровой погоды
		
		-- if zp.v and workpause then -- отправляем оповещение в ВК о зарплате в определенные минуты
		-- 	if os.date('%M:%S') == "50:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 10 минут.")
		-- 	elseif os.date('%M:%S') == "55:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 5 минут.")
		-- 	elseif os.date('%M:%S') == "59:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 1 минута.")
		-- 	elseif os.date('%M:%S') == "59:30" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 30 секунд.")
		-- 	end
		-- end
		--addGangZone(1001, -2080.2, 2200.1, -2380.9, 2540.3, 0x11011414) менее светлый цвет
		armourNew = getCharArmour(PLAYER_PED) -- получаем броню
		healNew = getCharHealth(PLAYER_PED) -- получаем ХП
		interior = getActiveInterior() -- получаем инту
		

		-- if healNew <= 3 then assDmg = false assTakeDamage = 0 end -- обнуляем 
		if not offmask and healNew == 0 then
			offMask = true
			offMaskTime = nil
		end

		-- получение названия района на инглише(работает только при включенном английском в настройках игры, иначе иероглифы)
		local zX, zY, zZ = getCharCoordinates(playerPed)
		ZoneInGame = getGxtText(getNameOfZone(zX, zY, zZ))
			
		-- определение города
		local citiesList = {'Los-Santos', 'San-Fierro', 'Las-Venturas'}
		local city = getCityPlayerIsIn(PLAYER_HANDLE)
		if city > 0 then playerCity = citiesList[city] else playerCity = "Нет сигнала" end


		-- назначаем переменным зоны по коордам и проверяем на нахождение персонажа в них
		vmfZone = isCharInArea2d(PLAYER_PED, -2072.8, 2206.0, -2333.6, 2559.6, false)
		vvsZone = isCharInArea2d(PLAYER_PED, 489.8, 2369.5, -122.3, 2594.6, false)
		svZone = isCharInArea2d(PLAYER_PED, 404.6, 1761.0, 69.8, 2129.2, false)
		avikZone = isCharInArea2d(PLAYER_PED, -1732.1, 247.0, -1161.7, 582.3, false)

		if gangzones.v then -- рисуем гангзоны военных объектов
			addGangZone(1001, -2072.8, 2559.6, -2333.6, 2206.0, 0x50511913) -- вмф зона
			addGangZone(1002, 489.8, 2594.6, -122.3, 2369.5, 0x50511913) -- ввс зона
			addGangZone(1003,  404.6, 2129.2, 69.8, 1761.0, 0x50511913) -- св зона
			addGangZone(1004, -1732.1, 247.0, -1161.7, 582.3, 0x50511913) -- авик
		else
			removeGangZone(1001)
			removeGangZone(1002)
			removeGangZone(1003)
			removeGangZone(1004)
		end
		

		-- задаем названия зонам по координатам
		if vmfZone then ZoneText = "Navy Base"
		elseif vvsZone then ZoneText = "Air Forces Base"
		elseif avikZone then ZoneText = "AirCraft Carrier"
		elseif svZone then ZoneText = "Ground Forces"
		else ZoneText = "-" end

		if zones.v and not workpause then -- показываем информер и его перемещение
			if not win_state['regst'].v then win_state['informer'].v = true end

			if mouseCoord then
				showCursor(true, true)
				infoX, infoY = getCursorPos()
				if isKeyDown(VK_RETURN) then
					infoX = math.floor(infoX)
					infoY = math.floor(infoY)
					mouseCoord = false
					showCursor(false, false)
					win_state['main'].v = not win_state['main'].v
					win_state['settings'].v = not win_state['settings'].v
				end
			end
		else
			win_state['informer'].v = false
		end

		if assistant.v and developMode == 1 and isPlayerSoldier then -- координатор и его перемещение
			if not win_state['regst'].v then win_state['ass'].v = true end

			if mouseCoord3 then
				showCursor(true, true)
				asX, asY = getCursorPos()
				if isKeyDown(VK_RETURN) then
					asX = math.floor(asX)
					asY = math.floor(asY)
					mouseCoord3 = false
					showCursor(false, false)
				end
			end
		else
			win_state['ass'].v = false
		end

		if state then -- показываем автострой и его перемещение
			win_state['find'].v = true
			if mouseCoord2 then
				showCursor(true, true)
				infoX2, infoY2 = getCursorPos()
				if isKeyDown(VK_RETURN) then
					infoX2 = math.floor(infoX2)
					infoY2 = math.floor(infoY2)
					mouseCoord2 = false
					showCursor(false, false)
					win_state['main'].v = not win_state['main'].v
					win_state['settings'].v = not win_state['settings'].v
				end
			end
		else
			win_state['find'].v = false
		end
		
		if hasPickupBeenCollected(pickup1) or hasPickupBeenCollected(pickup1a) then -- если подобрали пикап скрипта, то удаляем его
			removeBlip(marker1)
			removePickup(pickup1)
			removePickup(pickup1a)
		end
		
		if files[1] then
			for i, k in pairs(files) do
				if k and not imgui.Process then imgui.Process = menu_spur.v or window_file[i].v end
			end
		else imgui.Process = menu_spur.v end
		
		imgui.Process = win_state['regst'].v or win_state['main'].v or win_state['update'].v or win_state['player'].v or win_state['base'].v or win_state['informer'].v or win_state['renew'].v or win_state['find'].v or win_state['ass'].v or win_state['leave'].v
		
		-- тут мы шаманим с блокировкой управления персонажа
		if menu_spur.v or win_state['settings'].v or win_state['leaders'].v or win_state['player'].v or win_state['base'].v or win_state['regst'].v or win_state['renew'].v or win_state['leave'].v then
			if not isCharInAnyCar(PLAYER_PED) then
				lockPlayerControl(true)
			end
		elseif droneActive then
			lockPlayerControl(true)
		elseif workpause then
			if userNick ~= "Shifu_Murano" then
				sampSetChatInputEnabled(false)
			end
			lockPlayerControl(true)
		else
			lockPlayerControl(false)
		end
		

		if armOn.v then -- отыгровка броника, при релоге скрипта, если броник был надет - отыграет, если подойдет по условиям.
			if (armourNew == 100 and armourStatus == 0) then
				sampSendChat("/me "..(lady.v and 'открыла' or 'открыл').." склад с новыми бронежилетами IOTV") 
				wait(250)
				sampSendChat("/me "..(lady.v and 'взяла' or 'взял').." новый бронежилет со склада и "..(lady.v and 'надела' or 'надел').." его на себя")
				armourStatus = 1
			end
			
			if armourNew <= 50 and armourStatus == 1 then	
				sampSendChat("/do Бронежилет получил повреждения, требуется замена.")
				armourStatus = 0
			end

		else
			if armourNew == 100 and armourStatus == 0 then
				armourStatus = 1
			elseif armourNew <= 50 and armourStatus == 1 then
				armourStatus = 0
			end
		end

		if wasKeyPressed(key.VK_H) and not sampIsChatInputActive() and not sampIsDialogActive() and strobesOn.v and isCharInAnyCar(PLAYER_PED) then strobes() end -- стробоскопы на H, не делал на гудок ибо не хочу

		if wasKeyPressed(key.VK_R) and not win_state['main'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v and isPlayerSoldier then -- меню взаимодействия на ПКМ + R
			local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if result then
				local tdd, id = sampGetPlayerIdByCharHandle(ped)
				if tdd then
					MenuName = sampGetPlayerNickname(id)
					MenuID = id
					win_state['player'].v = not win_state['player'].v
				end
			end
		end
			

		-- тут у нас идет приветствие на ПКМ + 1
		if wasKeyPressed(key.VK_1) and not win_state['main'].v and not win_state['player'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v and isPlayerSoldier then
			local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			-- варианты для рандома
			local table = {
				'Здравия желаю',
				'здравия желаю'
			}
			if result then
				local tdd, id = sampGetPlayerIdByCharHandle(ped)
				if tdd then
					local pSkin = getCharModel(ped)
					local name = string.gsub(sampGetPlayerNickname(id), ".*_", "")
					sampSendChat("/anim 59")
					wait(150)
					if pSkin == 191 then -- бабоскин на "мэм"
						sampSendChat("/todo Поприветствовав женщину в форме*"..table[math.random(1, #table)]..", мэм.")
					elseif pSkin == 73 or pSkin == 179 or pSkin == 253 or pSkin == 255 or pSkin == 287 or pSkin == 61 then -- мужиков на "мистер"
						sampSendChat("/todo Поприветствовав военного*"..table[math.random(1, #table)]..", мистер "..name.."!")
					else -- бомжей как обычно
						sampSendChat("/todo Поприветствовав человека напротив*"..table[math.random(1, #table)].."!")
					end
				end
			end
		end

		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- это мы получаем маркер/таргет последнего игрока
		if result then
			local tdd, id = sampGetPlayerIdByCharHandle(ped)
			if tdd then
				if marker.v then
					blipID = id
					if newmark ~= nil then removeBlip(newmark) end
					newmark = addBlipForChar(ped)
					changeBlipColour(newmark, 4)
				else
					if id ~= blipID then
						blipID = id
						newmark = true
					end
				end
			end
		end

		if keyT.v then -- чат на русскую Т
			if(isKeyDown(key.VK_T) and wasKeyPressed(key.VK_T))then
				if(not sampIsChatInputActive() and not sampIsDialogActive()) then
					sampSetChatInputEnabled(true)
				end
			end
		end


		for i = 0, sampGetMaxPlayerId(true) do -- отключаем "вх" камхака для игроков, оставляем для разрабов.
			if sampIsPlayerConnected(i) then
				local result, ped = sampGetCharHandleBySampPlayerId(i)
				if result then
					local positionX, positionY, positionZ = getCharCoordinates(ped)
					local localX, localY, localZ = getCharCoordinates(PLAYER_PED)
					local distance = getDistanceBetweenCoords3d(positionX, positionY, positionZ, localX, localY, localZ)
					if distance >= 30 and droneActive and developMode ~= 1 then
						EmulShowNameTag(i, false)
					elseif droneActive and developMode == 1 then
						EmulShowNameTag(i, true)
					else
						EmulShowNameTag(i, true)
					end
				end
			end
		end
	end
end

function genCode(skey) -- генерация гугл ключа для автогугла
	skey = basexx.from_base32(skey)
	value = math.floor(os.time() / 30)
	value = string.char(
		0, 0, 0, 0,
		bit.band(value, 0xFF000000) / 0x1000000,
		bit.band(value, 0xFF0000) / 0x10000,
		bit.band(value, 0xFF00) / 0x100,
		bit.band(value, 0xFF)
	)
	local hash = sha1.hmac_binary(skey, value)
	local offset = bit.band(hash:sub(-1):byte(1, 1), 0xF)
	local function bytesToInt(a,b,c,d)
		return a*0x1000000 + b*0x10000 + c*0x100 + d
	end
	hash = bytesToInt(hash:byte(offset + 1, offset + 4))
	hash = bit.band(hash, 0x7FFFFFFF) % 1000000
	return ("%06d"):format(hash)
end

function EmulShowNameTag(id, value) -- эмуляция показа неймтэгов над бошкой
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteBool(bs, value)
    raknetEmulRpcReceiveBitStream(80, bs)
    raknetDeleteBitStream(bs)
end

function sampGetPlayerIdByNickname(nick) -- получаем id игрока по нику
    if type(nick) == "string" then
        for id = 0, 1000 do
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if sampIsPlayerConnected(id) or id == myid then
                local name = sampGetPlayerNickname(id)
                if nick == name then
                    return id
                end
            end
        end
    end
end

function onQuitGame()
	saveSettings(2) -- сохраняем игру при выходе
end

function onScriptTerminate(script, quitGame) -- действия при отключении скрипта
	if script == thisScript() then
		showCursor(false)
		saveSettings(1)
		
		if marker.v then removeBlip(newmark) end -- удаляем маркер
		if quitGame == false then
			bass.BASS_ChannelPlay(aerr, false) -- воспроизводим звук краша
			lockPlayerControl(false) -- снимаем блок персонажа на всякий
			sampTextdrawDelete(102) -- удаляем текстдрав от VK Int на всякий.

			if not reloadScript then -- выводим текст
				sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка, скрипт завершил свою работу принудительно.", 0x046D63)
				sampAddChatMessage("[Army Assistant]{FFFFFF} Свяжитесь с разработчиком для уточнения деталей проблемы.", 0x046D63)
			end
			if workpause then -- если был активен VK-Int, то вырубаем его
				memory.setuint8(7634870, 0)
        		memory.setuint8(7635034, 0)
        		memory.hex2bin('5051FF1500838500', 7623723, 8)
				memory.hex2bin('0F847B010000', 5499528, 6)
			end

			if droneActive then -- выходим из дрона и отрубаем все от него возможное
				setInfraredVision(false)
				setNightVision(false)
				restoreCameraJumpcut()
				setCameraBehindPlayer()
				flymode = 0
				droneActive = false
			end
		end
	end
end

function saveSettings(args, key) -- функция сохранения настроек, args 1 = при отключении скрипта, 2 = при выходе из игры, 3 = сохранение клавиш + текст key, 4 = обычное сохранение.

	if aaudio ~= nil then
		bass.BASS_StreamFree(aaudio)
	end
	if doesFileExist(bfile) then
		os.remove(bfile)
	end
	local f = io.open(bfile, "w")
	if f then
		f:write(encodeJson(tBindList))
		f:close()
	end

	if doesFileExist(bindfile) then
		os.remove(bindfile)
	end
	local f2 = io.open(bindfile, "w")
	if f2 then
		f2:write(encodeJson(mass_bind))
		f2:close()
	end

	ini.vkint.zp = zp.v
	ini.vkint.nickdetect = nickdetect.v
	ini.vkint.pushv = pushv.v
	ini.vkint.smsinfo = smsinfo.v
	ini.vkint.remotev = remotev.v
	ini.vkint.getradio = getradio.v
	ini.vkint.familychat = familychat.v

	ini.informer.zone = infZone.v
	ini.informer.hp = infHP.v
	ini.informer.armour = infArmour.v
	ini.informer.city = infCity.v
	ini.informer.kv = infKv.v
	ini.informer.time = infTime.v
	ini.informer.rajon = infRajon.v
	ini.informer.mask = infMask.v

	ini.settings.rpinv = rpinv.v
	ini.settings.rpuninv = rpuninv.v
	ini.settings.rpuninvoff = rpuninvoff.v
	ini.settings.rpskin = rpskin.v
	ini.settings.rprang = rprang.v

	ini.settings.rpFind = rpFind.v
	ini.settings.rpblack = rpblack.v
	ini.settings.smssound = smssound.v
	ini.settings.rptime = rptime.v
	ini.settings.assistant = assistant.v
	ini.settings.screenSave = screenSave.v
	ini.settings.keyT = keyT.v
	ini.settings.marker = marker.v
	ini.settings.timefix = timefix.v
	ini.settings.enableskin = enableskin.v
	ini.settings.skin = localskin.v
	ini.settings.gnewstag = u8:decode(gnewstag.v)
	ini.settings.inComingSMS = inComingSMS.v
	ini.settings.specUd = specUd.v
	ini.settings.timecout = timecout.v
	ini.settings.gangzones = gangzones.v
	ini.settings.zones = zones.v
	ini.settings.ads = ads.v
	ini.settings.chatInfo = chatInfo.v
	ini.settings.infoX = infoX
	ini.settings.infoY = infoY
	ini.settings.infoX2 = infoX2
	ini.settings.infoY2 = infoY2
	ini.settings.findX = findX
	ini.settings.findY = findY
	ini.settings.tag = u8:decode(rtag.v)

	ini.settings.autopass = u8:decode(autopass.v)
	ini.settings.googlekey = u8:decode(googlekey.v)
	ini.settings.autologin = autologin.v
	ini.settings.autogoogle = autogoogle.v

	ini.assistant.asX = asX
	ini.assistant.asY = asY

	ini.settings.enable_tag = enable_tag.v
	ini.settings.gos1 = u8:decode(gos1.v)
	ini.settings.gos2 = u8:decode(gos2.v)
	ini.settings.gos3 = u8:decode(gos3.v)
	ini.settings.gos4 = u8:decode(gos4.v)
	ini.settings.gos5 = u8:decode(gos5.v)
	ini.settings.phoneModel = u8:decode(phoneModel.v)
	ini.settings.timerp = u8:decode(timerp.v)
	ini.settings.timeBrand = u8:decode(timeBrand.v)
	ini.settings.spOtr = u8:decode(spOtr.v)
	ini.settings.lady = lady.v
	ini.settings.timeToZp = timeToZp.v
	ini.settings.gateOn = gateOn.v
	ini.settings.lockCar = lockCar.v
	ini.settings.strobes = strobesOn.v
	ini.settings.armOn = armOn.v
	inicfg.save(SET, "/MoD-Helper/settings.ini")
	if args == 1 then
		print("============== SCRIPT WAS TERMINATED ==============")
		print("Настройки и клавиши сохранены в связи.")
		print("MoD-Helper by X.Adamson, version: "..thisScript().version)
		print("Script mode: "..tostring(developMode)..", VK: "..tostring(vkinf))

		if doesFileExist(getWorkingDirectory() .. '\\MoD-Helper\\files\\regst.data') then
			print("File regst.data is finded")
		else
			print("File regst.data not finded")
		end
		print("==================================================")
	elseif args == 2 then
		print("============== GAME WAS TERMINATED ===============")
		print("==================================================")
	elseif args == 3 and key ~= nil then
		print("============== "..key.." SAVED ==============")
	elseif args == 4 then
		print("============== SAVED ==============")
	end
end

function sampev.onPlayerChatBubble(id, color, distance, dur, text)
	if droneActive and developMode == 1 then -- тут мы меняем дальность действия текста над бошкой и для разрабов при камхаке(дроне) расширяем
		return {id, color, 1488, dur, text}
	end
end

-- обработка диалогов
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)

	if title:find("Код с приложения") and text:find("Система безопасности") and autogoogle.v then -- автогугл
		sampSendDialogResponse(dialogId, 1, 0, genCode(u8:decode(googlekey.v)))
		sampAddChatMessage("[MoD-Auth] {FFFFFF}Google Authenticator пройден по коду: "..genCode(u8:decode(googlekey.v)), 0x046D63)
		return false
	end

	if title:find("Авторизация") and text:find("Добро пожаловать") and autologin.v then -- автологин
		sampSendDialogResponse(dialogId, 1, 0, u8:decode(autopass.v))
		sampAddChatMessage("[MoD-Auth] {FFFFFF}Установленный вами пароль был автоматически введен.", 0x046D63)
		return false
	end

	-- достаем номер аккаунта человека из доната
	--[[if regAcc and title:find("Меню игрока") then 
			sampSendDialogResponse(dialogId, 1, 10, -1)
			return false
	end
	if regAcc and title:find("Дополнительные возможности") then
            print("LOG text:\n"..text)
			playerAccoutNumber = tostring(text:match("Номер аккаунта:\t(.*)\nТекущее"))
            print(tostring("NUMBER: "..playerAccountNumber))
			if playerAccoutNumber ~= nil then
				regAcc = false
				ScriptUse = 5
				return false
			else
				ScriptUse = 4
				return false
			end
	end]]--

	if title:find("Члены подразделения онлайн") and isPlayerSoldier then -- обработка финда для отыгровки и автостроя. Автострой сделан максимально убого, пример не из лучших.
			if rpFind.v then
				findCout = text:match("Из них онлайн:\t(.*)\n")
				findCout = all_trim(findCout)
				findCout = tonumber(findCout)
				if findCout == nil then findCout = 40 end
			end
			
			names = {}
			SecNames = {}
			SecNames2 = {}
			namID = {}
			secID = {}
			sec2ID = {}
			for w in text:gmatch('[^\r\n]+') do
				local id = w:match('%d+\t\t%d+\t%d+\t\t%a+_%a+%[(%d+)%]')
				local afk2 = w:match('%[%d+%](.+)')

				if id ~= nil and id ~= myID then
					local _, handle = sampGetCharHandleBySampPlayerId(id)
					if doesCharExist(handle) then
						local x, y, z = getCharCoordinates(handle)
						local mx, my, mz = getCharCoordinates(PLAYER_PED)
						local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)

						if dist <= 25 then
							names[#names+1] = sampGetPlayerNickname(id):gsub('_', ' ')
						else
							SecNames[#SecNames+1] = sampGetPlayerNickname(id):gsub('_', ' ')
							secID[#secID+1] = id
						end
					else
						SecNames2[#SecNames2+1] = sampGetPlayerNickname(id):gsub('_', ' ')
						sec2ID[#sec2ID+1] = id
					end
				end
			end
	end

	if dialogId == 176 and title:match("Точное время") then -- обработка диалога /time
			if timecout.v then -- счетчик чистого онлайна в чат
				local houtyet, minyet = text:match("Время в игре сегодня:		{ffcc00}(%d+) ч (%d+) мин")
				local houtyet1, minyet1 = text:match("AFK за сегодня:		{FF7000}(%d+) ч (%d+) мин")
				local outhour =  houtyet - houtyet1
				local outmin = minyet - minyet1
				if string.find(outmin, "-") then
					outmin = outmin + 60
					outhour = outhour - 1
				end
				sampAddChatMessage("[Army Assistant]{FFFFFF} Чистый онлайн: "..outhour.." ч "..outmin.." мин.", 0x046D63)
			end
			
			if timeToZp.v then 
				sampAddChatMessage("[Army Assistant]{FFFFFF} До выплаты почасовой зарплаты - "..60-os.date('%M').." минут.", 0x046D63)
			end

			if rptime.v then -- Рп часы
				if timerp.v == '' then
					if timeBrand.v == '' then
						sampSendChat("/me вытянув руку, "..(lady.v and 'посмотрела' or 'посмотрел').." на армейские часы")
						
					else
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы бренда «"..u8:decode(timeBrand.v).."».")
					end
				else
					if timeBrand.v == '' then
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы c гравировкой «"..u8:decode(timerp.v).."».")
					else
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы бренда «"..u8:decode(timeBrand.v).."» c гравировкой «"..u8:decode(timerp.v).."».")
					end
				end
				sampShowDialog(176,title,text,button1,button2,style)
			end
			return
	end

	--[[if getLeader and title:find("Лидеры") and isLocalPlayerSoldier then -- получаем список лидеров МО
			if text:find("Мин. обороны") then getMOLeader = text:match(".*\n(.*)\tМин. обороны\tМинистр обороны") end
			if text:find("Сухопутные войска") then getSVLeader = text:match(".*\n(.*)\tСухопутные войска\tГенерал")	end
			if text:find("Военно%-воздушные силы") then getVVSLeader = text:match(".*\n(.*)\tВоенно%-воздушные силы\tГенерал") end
			if text:find("Военно%-морской флот") then getVMFLeader = text:match(".*\n(.*)\tВоенно%-морской флот\tАдмирал") end
			sampSendDialogResponse(dialogId, 1, 0, -1)
			print("Список лидеров подргружен")
			getLeader = false
			return false
	end--]]
		
	if dialogId == 436 and checking then -- работа с диалогом истории ников для чекера на ЧСников
			title = title:match("Прошлые имена (.*)")
			text = text:gsub('{.-}', '')
			text = text:gsub('До %d+.%d+.%d+', '')
			for nicknames in text:gmatch('\t(.*)\n') do
				nicknames = nicknames:gsub("\t", "")
				nicknames = nicknames:gsub("\n", " ")
				for k, v in ipairs(blackbase) do
					if v[1]~= nil then
						if nicknames:find(v[1]) then
							sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{DC143C}Игрок "..v[1].." найден в черном списке.\nПричина занесения: "..u8:decode(v[2]), "Закрыть", "", 0)
							bstatus = 1
							checking = false
							break
						end
					end
				end

				if button2 ~= '' and checking then
					sampSendDialogResponse(436, 1, -1, '')
				end
				if button2 == '' and not checking then
					checking = false
					sampSendDialogResponse(436, 1, -1, '')
					sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
					bstatus = 2
				end
				if button2 == '' and checking then
					checking = false
					sampSendDialogResponse(436, 1, -1, '')
					sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
					bstatus = 2
				end
			end
			return false
	end
	if text:find('История изменения имён персонажа пуста') and checking and not pidr then 
			sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
			bstatus = 2
			checking = false
			return false
	end

		-- считывание статистики игрока после спавна на сервере, с последующей обработкой
	if regDialogOpen and title:find("Меню игрока") then -- получение данных статистики
			sampSendDialogResponse(dialogId, 1, 0, -1)
			return false
	elseif regDialogOpen and title:find("Статистика игрока") then
		
			org = text:match("Организация: 		(.*)\nПодр")
			preorg = text:match("работа 		(.*)\nРабота")
			rang = text:match("ранг: 		%[.+%]:(.*)\nРанг")
			
			-- если организация не nil или любая, но не Мин.Обороны - ScriptUse = 0, иначе - переименование подфракций.
			if org ~= nil then
				nasosal_rang = tonumber(text:match("Ранг:				(%d+)\n\nПроживание"))
				if org:find("Министерство обороны") then
					org = "Ministry of Defence"
					if preorg:find("Сухопутные войска") then
						fraction = "Сухопутные Войска"
						arm = 1
						mtag = "G.F."
					elseif preorg:find("Военно%-Воздушные силы") then
						fraction = "Военно-Воздушные Силы"
						arm = 2
						mtag = "A.F."
					elseif preorg:find("Военно%-морской флот") then
						fraction = "Военно-Морской Флот"
						arm = 3
						mtag = "Navy"
					elseif preorg:find("Мин. обороны") then
						fraction = "Minister of Defence"
						arm = 4
						mtag = "M"
					end

					if rang ~= "0" then
						rang = all_trim(tostring(rang))
					end
					isLocalPlayerSoldier = true
					ScriptUse = 1
				else
					if preorg:find("ЛС") or preorg:find("LS") then mtag = "LS"
					elseif preorg:find("СФ") or preorg:find("SF") then mtag = "SF"
					elseif preorg:find("ЛВ") or preorg:find("LV") then mtag = "LV"
					else mtag = "-" end
					arm = 5	
					if rang ~= "—" then
						rang = all_trim(tostring(rang))
					end
					nasosal_rang = 1
					ScriptUse = 0
				end
			else
				nasosal_rang = 1
				arm = 5
				preorg = "Гражданский"
				mtag = "SA"
				rang = 0
				ScriptUse = 0
			end
			regDialogOpen = false
			return false
	end
end

function strobes() -- стробоскопы, не мои, автора не могу точно сказать, ибо эти стробоскопы то один делал, то второй, то третий, я лишь чутка их поправил
	if not isCharOnAnyBike(PLAYER_PED) and not isCharInAnyBoat(PLAYER_PED) and not isCharInAnyHeli(PLAYER_PED) and not isCharInAnyPlane(PLAYER_PED) then
		if not enableStrobes then
			enableStrobes = true
			lua_thread.create(function()
				vehptr = getCarPointer(storeCarCharIsInNoSave(PLAYER_PED)) + 1440
				while enableStrobes and isCharInAnyCar(PLAYER_PED) do
					-- 0 левая, 1 правая фары, 3 задние
					callMethod(7086336, vehptr, 2, 0, 0, 0)
					callMethod(7086336, vehptr, 2, 0, 1, 1)
					wait(150)
					callMethod(7086336, vehptr, 2, 0, 0, 1)
					callMethod(7086336, vehptr, 2, 0, 1, 0)
					wait(150)
					if not isCharInAnyCar(PLAYER_PED) then
						enableStrobes = false
						break
					end
				end
				callMethod(7086336, vehptr, 2, 0, 0, 0)
				callMethod(7086336, vehptr, 2, 0, 1, 0)
			end)
		else
			enableStrobes = false
		end
	end
end


-- подключение шрифта для работы иконок
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
		font_config.MergeMode = true
	
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/MoD-Helper/files/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end
end

function imgui.ToggleButton(str_id, bool) -- функция хомяка

	local rBool = false
 
	if LastActiveTime == nil then
	   LastActiveTime = {}
	end
	if LastActive == nil then
	   LastActive = {}
	end
 
	local function ImSaturate(f)
	   return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
  
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
 
	local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15
 
	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
	   bool.v = not bool.v
	   rBool = true
	   LastActiveTime[tostring(str_id)] = os.clock()
	   LastActive[str_id] = true
	end
 
	local t = bool.v and 1.0 or 0.0
 
	if LastActive[str_id] then
	   local time = os.clock() - LastActiveTime[tostring(str_id)]
	   if time <= ANIM_SPEED then
		  local t_anim = ImSaturate(time / ANIM_SPEED)
		  t = bool.v and t_anim or 1.0 - t_anim
	   else
		  LastActive[str_id] = false
	   end
	end
 
	local col_bg
	if imgui.IsItemHovered() then
	   col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
	   col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
	end
 
	draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))
 
	return rBool
end


function imgui.OnDrawFrame()
	local tLastKeys = {} -- это у нас для клавиш
	local sw, sh = getScreenResolution() -- получаем разрешение экрана
	local btn_size = imgui.ImVec2(-0.1, 0) -- а это "шаблоны" размеров кнопок
	local btn_size2 = imgui.ImVec2(160, 0)
	local btn_size3 = imgui.ImVec2(140, 0)

	-- тут мы подстраиваем курсор под адекватность
	imgui.ShowCursor = not win_state['informer'].v and not win_state['ass'].v and not win_state['find'].v or win_state['main'].v or win_state['base'].v or win_state['update'].v or win_state['player'].v or win_state['regst'].v or win_state['renew'].v or win_state['leave'].v

	if win_state['main'].v then -- основное окошко
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(280, 230), imgui.Cond.FirstUseEver)
		imgui.Begin(u8' MoD-Helper by Adamson', win_state['main'], imgui.WindowFlags.NoResize)

		-- кнопка информации, визуально реализовано частично
		-- if isPlayerSoldier then if imgui.Button(fa.ICON_STAR..u8' Информация', btn_size) then print("Переход в раздел информации") win_state['info'].v = not win_state['info'].v end end
		-- кнопка настроек, готово
		
		if imgui.Button(fa.ICON_COGS..u8' Настройки', btn_size) then print("Переход в раздел настроек") win_state['settings'].v = not win_state['settings'].v end
		-- кнопка шпоры, готово
		if imgui.Button(fa.ICON_YELP..u8' Шпаргалки', btn_size) then print("Переход в раздел шпор") menu_spur.v = not menu_spur.v end
		-- лидерский раздел(госки), готово
		if imgui.Button(fa.ICON_CHILD..u8' Лидерам', btn_size) then print("Переход в раздел лидерам") win_state['leaders'].v = not win_state['leaders'].v end
		-- информация по скрипту, готово
		if imgui.Button(fa.ICON_EYE..u8' Помощь', btn_size) then print("Переход в раздел помощи") win_state['help'].v = not win_state['help'].v end
		-- о скрипте, установка обновлений, готово
		if imgui.Button(fa.ICON_COPYRIGHT..u8' О скрипте', btn_size) then print("Переход в раздел о скрипте") win_state['about'].v = not win_state['about'].v end
	
		imgui.End()
	end

	if win_state['player'].v then -- окно меню взаимодействия
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(380, 260), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Взаимодействие с '..MenuName..'['..MenuID..']', win_state['player'], imgui.WindowFlags.NoResize)
		
		local mname = sampGetPlayerNickname(MenuID):gsub("_", " ")
		local pcolor = sampGetPlayerColor(MenuID)
		
		if pcolor ~= 4288243251 then -- если клист не военный
			if nasosal_rang >= 9 then
				if imgui.Button(fa.ICON_PAW..u8' Принять', btn_size) then
					sampProcessChatInput("/invite "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		else
			if nasosal_rang >= 9 then
				if imgui.CollapsingHeader(fa.ICON_JSFIDDLE..u8' Действия с рангами') then
					if imgui.Button(fa.ICON_PAW..u8' Повысить игрока', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 +")
					end
					if imgui.Button(fa.ICON_PAW..u8' Понизить игрока', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 -")
					end
				end
			end
			if nasosal_rang >= 5 then
				if imgui.CollapsingHeader(fa.ICON_LINUX..u8' Выдать нашивку') then
					imgui.InputText(u8'Спец.отряд', specOtr)
					imgui.InputText(u8'Позывной', pozivnoy)
					if imgui.Button(fa.ICON_PAW..u8' Выдать', btn_size) then
						if #specOtr.v <= 3 or #pozivnoy.v <= 3 then 
							sampAddChatMessage("[Army Assistant]{FFFFFF} Слишком короткое название спец.отряда или позывного.", 0x046D63)
						else
							sampSendChat(string.format("/me "..(lady.v and 'достала' or 'достал').." и "..(lady.v and 'выдала' or 'выдал').." заготовленную нашивку бойца %s", mname))
							sampSendChat(string.format("/do Выдана нашивка: %s | %s | %s.", mtag,  u8:decode(specOtr.v), u8:decode(pozivnoy.v)))
							specOtr.v = ''
							pozivnoy.v = ''
						end
					end
				end

				if imgui.CollapsingHeader(fa.ICON_HEART..u8' Общий мед.осмотр') then
					if imgui.Button(fa.ICON_PAW..u8' Представиться', btn_size) then
						lua_thread.create(function()
							sampSendChat("Здравия желаю, сейчас мы проведем вам мед.осмотр.") 
							wait(2500)
							sampSendChat("Назовите ваше имя, фамилию, рост, а так же вес.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Уточнить жалобы на здоровье', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo Заполнив данные в мед.документе*Хорошо, имеются жалобы на здоровье?") 
							wait(2500)
							sampSendChat("Быть может вас что-то беспокоит, тревожит? Нам надо знать все.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Проверить глаза', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo Записав информацию*Ладно, так, нужно проверить ваши глаза.") 
							wait(2500)
							sampSendChat("Мы проверим реакцию ваших зрачков на свет, если все хорошо - продолжим осмотр.") 
							wait(2500)
							sampSendChat("В ином случае, нам придется направить вас к окулисту для дальнейшей консультации.")
							wait(4000)
							sampSendChat("/me достав фанарик из кармана, включив его и подойдя к человеку - начали проверку глаз")
							wait(1250)
							sampSendChat("/n Напиши в чат, /do Зрачки расширялись или /do Зрачки не расширялись.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Зрачки реагируют', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Посветив фонариком в каждый глаз*Ну что же..")
							wait(2500)
							sampSendChat("Ваши зрачки реагируют на свет, это уже хорошо.") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' Зрачки не реагируют', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Посветив фонариком в каждый глаз*Ну что же..")
							wait(2500)
							sampSendChat("Наблюдаю отсутствие реакции зрачков на свет, это плохо.")
							wait(2500)
							sampSendChat("Направляю вас к окулисту в городскую больницу, а пока что мед.осмотр не пройден.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Попросить раздеться', btn_size) then
						lua_thread.create(function()
							sampSendChat("Так, сейчас мне необходимо проверить ваше тело на внешние признаки.") 
							wait(2500)
							sampSendChat("Пожалуйтса, разденьтесь по пояс.") 
							wait(2500)
							sampSendChat("/n Через /do отыграй, есть ли шрамы, раны и в этом духе.") 
							wait(2500)
							sampSendChat("/n Например, /do Никаких внешних признаков нет или же /do Имеются шрамы.")
							wait(2500)
							sampSendChat("/n Включи фантазию, а там видно будет") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Удачный осмотр', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Осмотрев человека*Одевайтесь обратно.") 
							wait(2500)
							sampSendChat("В целом никаких нарушений не выявлено, осмотр пройден успешно.") 
							wait(2500)
							sampSendChat("Если все же возникнут какие то проблемы со здоровьем - обращайтесь!") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' Неудачный осмотр', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Осмотрев человека*Одевайтесь обратно.") 
							wait(2500)
							sampSendChat("Ваши показания свидетельствуют о ваших проблемах с организмом.") 
							wait(2500)
							sampSendChat("Мед.комиссию вы не прошли, обратитесь к врачу и возвращайтесь после выздоравления!") 
						end)
					end
				end
				
				if imgui.CollapsingHeader(fa.ICON_QQ..u8' Благодарности') then
					if nasosal_rang >= 9 then
						if imgui.Button(fa.ICON_PAW..u8' За помощь на призыве', btn_size) then
							sampSendChat(mname.. ", благодарю вас за помощь на призыве.")				
						end
						if imgui.Button(fa.ICON_PAW..u8' За помощь на всеобщем', btn_size) then
							sampSendChat(mname.. ", благодарю вас за помощь на всеобщем повышении.")				
						end
					end
					if imgui.Button(fa.ICON_PAW..u8' За участие в тренировке', btn_size) then
						sampSendChat(mname.. ", благодарю вас за участие в тренировке.")				
					end
				end
			end
			imgui.NewLine()
			if nasosal_rang >= 8 then
				if imgui.Button(fa.ICON_RANDOM..u8' Сменить скин', btn_size) then
					sampProcessChatInput("/changeskin "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		end
		if imgui.Button(fa.ICON_REPEAT..u8' Проверить на ЧС МО', btn_size) then
			lua_thread.create(function()
				win_state['player'].v = not win_state['player'].v
				sampSendChat(mname..", сейчас мы проверим ваше наличие в черном списке Мин.Обороны.")
				wait(1500)
				sampProcessChatInput("/black "..MenuID)
			end)
		end
		if imgui.Button(fa.ICON_USER..u8' Показать автоотчет', btn_size) then
			win_state['player'].v = not win_state['player'].v
			sampSendChat("/team "..MenuID)
		end	
		imgui.End()
	end

	if win_state['info'].v then -- окно с информацией
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(930, 450), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('Информация'), win_state['info'], imgui.WindowFlags.NoResize)
        imgui.BeginChild('left pane', imgui.ImVec2(200, 0), true)
		
		-- создание пунктов путем цикла, который берет пункты из массива(так мне говорил Igor Novikov, разраб MM Editor)
		for i = 1, #SeleList do
			if imgui.Selectable(u8(SeleList[i]),SeleListBool[i]) then selected = i end
			imgui.Separator()
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginGroup()
		
		-- все меню каждого блока
        if selected == 1 then -- вывод статистики с базы			
			
			imgui.Text(fa.ICON_INFO..u8" Информация о вас в базе данных Ministry of Defence:\n")
			imgui.SameLine()
			showHelp(u8'Информация берется из онлайн базы данных. Любая попытка модифицировать/изменить/подделать несанкционированным путем может быть присечена ограничением доступа, вплоть до пожизненного ограничения доступа к пользованию.')
			imgui.Separator()
			
			if activated then
				imgui.Text(fa.ICON_ID_CARD..u8' Идентификатор бойца: ')
				imgui.SameLine()
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), superID)
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Ваше имя и фамилия: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), nickName)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Подразделение, в котором служите: ')
			imgui.SameLine()			
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8""..tostring(org).." | ".. u8""..tostring(fraction).. "[ID: "..tostring(arm).."]")
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Занимаемая должность: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8(tostring(rang)))
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Уровень доступа: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.71, 0.40 , 0.04, 1.0), accessD)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Количество выговоров: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), vigcout.."".. u8"/3 выговоров")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Количество нарядов: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), narcout.."".. u8" активных нарядов")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Наград за воинские заслуги: ')
			imgui.SameLine()
			if activated then	
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), order.."".. u8" наград(-ы)")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Наличие в белом списке: ')
			imgui.SameLine()
			if whitelist == 0 then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Не состоит в белом списке")
			elseif whitelist == 1 then imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"Подтверждено")
			else imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены") end
			
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Комментарий руководства о вас: ')
			imgui.SameLine()
			if activated then	
				imgui.TextWrapped(rAbout)
			else
				imgui.TextWrapped(u8'Боец, который всегда выполняет поставленные задачи независимо от сложности. Имеет склонность к игнорированию приказов, что ведет к неоправданным рискам при выполнении военных операций.')
			end
			
			imgui.Separator()
			if not activated then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), fa.ICON_WARNING..u8"[ВНИМАНИЕ] Активен ограниченный режим. Часть данных недоступна, функционал скрипта ограничен.") end
			imgui.SetCursorPos(imgui.ImVec2(420, 325))
			imgui.Image(classifiedPic, imgui.ImVec2(220, 120))
		
		elseif selected == 2 then -- вывод списка МОшных лидеров	
			imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
			imgui.Image(mlogo, imgui.ImVec2(180, 180))
			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(490, 220))
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), u8'Ministry of Defence')
			--imgui.Separator()
			imgui.SetCursorPos(imgui.ImVec2(270, 242))
			imgui.Text(u8'Является исполнительной властью отдела федерального правительства Соединенных Штатов')
			imgui.SetCursorPos(imgui.ImVec2(385, 254))
			imgui.Text(u8' и поручено координировать, а так же контролировать все')
			imgui.SetCursorPos(imgui.ImVec2(340, 266))
			imgui.Text(u8' органы и функции соответствующего правительства непосредственно')
			imgui.SetCursorPos(imgui.ImVec2(400, 278))
			imgui.Text(u8' национальной безопасности Соединенных Штатов.')

			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(445, 305))
			imgui.Text(u8"Министр Обороны - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getMOLeader))
			imgui.SetCursorPos(imgui.ImVec2(340, 320))
			imgui.Text(u8"Генерал US Ground Force штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getSVLeader))
			imgui.SetCursorPos(imgui.ImVec2(355, 335))
			imgui.Text(u8"Генерал US Air Force штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVVSLeader))
			imgui.SetCursorPos(imgui.ImVec2(385, 350))
			imgui.Text(u8"Адмирал US Navy штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVMFLeader))

		elseif selected == 3 then
			if dostupLvl ~= nil or developMode == 1 then
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(pentagonPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'База данных Пентагона | '..accessD..'.')
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8('Вы идентифицированы как '..nickName..', '..u8:decode(accessD)..' подтвержден.'))
				imgui.Separator()
				imgui.Text(u8'• Ввиду наличия допуска к материалам пентагона, вы можете просматривать базу данных используя свой КПК.')
				imgui.Text(u8'• Любая попытка подделки или же подача ложных данных пресекается техниками Пентагона.')
				imgui.Text(u8'• Распространение полученной информации запрещается без согласования с начальством.')
				imgui.TextWrapped(u8'• Если вы фиксируете наличие заведомо ложной информации или же расцениваете ее некорректной - сообщите техникам, дабы исправить недочеты.')
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8("КПК доступен по /base."))
			else
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(accessDeniedPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'Доступ запрещен.')
				imgui.TextWrapped(u8'Нами зафиксирована и пресечена попытка получить несанционированный доступ к пользовательской информации закрытых баз данных Пентагона. Санкционируйте доступ у уполномоченных лиц.')
			end
		end
		
		if selected ~= 0 then
			clearSeleListBool(selected) 
		end
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['settings'].v then -- окно с настройками
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(850, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Настройки', win_state['settings'], imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
		if imgui.BeginMenuBar() then -- меню бар, используется в виде выпадающего списка, ибо горизонтальный с ума сходит и мерцает при клике по одному из пунктов
			if imgui.BeginMenu(fa.ICON_PAW..u8(" Навигация по настройкам")) then
				if developMode == 1 then
					if imgui.MenuItem(fa.ICON_CONNECTDEVELOP..u8" Меню разработчика") then
						showSet = 1
					end
				end
				if imgui.MenuItem(fa.ICON_BARS..u8(" Основное")) then
					showSet = 2
					print("Настройки: Основное")
				elseif imgui.MenuItem(fa.ICON_KEYBOARD_O..u8(" Клавиши")) then
					showSet = 3
					print("Настройки: Клавиши")
				--[[elseif imgui.MenuItem(fa.ICON_VK..u8(" int.")) then
					showSet = 4
					print("Настройки: VK Int")]]--
				elseif imgui.MenuItem(fa.ICON_INDENT..u8(" Биндер")) then
					showSet = 5
					print("Настройки: Биндер")
				end
				 if assistant.v and developMode == 1 and isPlayerSoldier then
				 	if imgui.MenuItem(fa.ICON_ANCHOR..u8(" Координатор")) then
				 		showSet = 6
				 		print("Настройки: Координатор")
				 	end
				 end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
		if showSet == 1 then -- что-то типо закрытого меню с красивым названием, но ничего кроме смены стилей тут нет.
			if developMode == 1 then
				if imgui.CollapsingHeader(u8("Редактор стилей")) then
					imgui.ShowStyleEditor()
				end
				if imgui.Button(u8("Стиль #1(default new)"), btn_size) then apply_custom_style() end
				if imgui.Button(u8("Стиль #2(old dark)"), btn_size) then new_style() end
			else
				showSet = 2
			end
		elseif showSet == 2 then -- общие настройки
			if imgui.CollapsingHeader(fa.ICON_COMMENTING..u8' Рация') then
				imgui.InputText(u8'Тэг в рацию', rtag)
				--[[if isPlayerSoldier then 
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_TUMBLR_SQUARE..u8(" Автотэг")); imgui.SameLine(); imgui.ToggleButton(u8"Автотэг", enable_tag)
					imgui.SameLine()
					showHelp(u8'При отправке сообщений в /f чат - сработает подстановка тэга, который укажет организацию и указанный вами тэг.\nОпределение организаций:\nGF(Ground Force) - Сухопутные Войска\nAF(AirForce) - Военно-Воздушные Силы\nN(Navy) - Военно-Морской Флот\nДля Министра Обороны системный тэг не устанавливается.')
				end]]--
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_FIRE..u8(" Таймскрин при докладе")); imgui.SameLine(); imgui.ToggleButton(u8"Таймскрин при докладе", screenSave)
				imgui.SameLine()
				showHelp(u8'При отправке доклада в /rd и /fd будет пробиваться время + автоматически сделается скриншот.')
			end
			if imgui.CollapsingHeader(fa.ICON_GIFT..u8' Модификации') then
				imgui.BeginChild('##as2dasasdf', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ChatInfo")); imgui.SameLine(); imgui.ToggleButton(u8'ChatInfo', chatInfo)

				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Женский пол")); imgui.SameLine(); imgui.ToggleButton(u8'Женский пол', lady)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Маркер игрока")); imgui.SameLine(); imgui.ToggleButton(u8'Маркер игрока', marker)
				imgui.NextColumn()
				-- if isPlayerSoldier then
				-- 	imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Координатор")); imgui.SameLine(); imgui.ToggleButton(u8'Координатор', assistant)
				-- end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Чат на клавишу Т")); imgui.SameLine(); imgui.ToggleButton(u8'Чат на клавишу T', keyT)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Звук входяшего СМС")); imgui.SameLine(); imgui.ToggleButton(u8'Звук входящего СМС', smssound)
				imgui.SameLine()
				showHelp(u8'При каждом входящем СМС будет проигрывать звук, который расположен в MoD-Helper/audio/sms.mp3. Вы можете выбрать любой другой звук, для этого скачайте его и замените и переименуйте в "sms", формат обязательно должен быть mp3.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Стробоскопы")); imgui.SameLine(); imgui.ToggleButton(u8'Стробоскопы', strobesOn)
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_GAMEPAD..u8' Информер MoD-Helper') then
				imgui.BeginChild('##25252', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Включить информер")); imgui.SameLine(); imgui.ToggleButton(u8'Включить информер', zones)
				if zones.v then
					imgui.SameLine()
					if imgui.Button(u8'Переместить') then 
						sampAddChatMessage("[Army Assistant]{FFFFFF} Выберите позицию и нажмите {00C2BB}Enter{FFFFFF} чтобы сохранить ее.", 0x046D63)
						win_state['settings'].v = not win_state['settings'].v 
						win_state['main'].v = not win_state['main'].v 
						mouseCoord = true 
					end
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Таймер маски")); imgui.SameLine(); imgui.ToggleButton(u8'Таймер маски', infMask)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение военной зоны")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение военной зоны', infZone)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение брони")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение брони', infArmour)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение здоровья")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение здоровья', infHP)
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение города")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение города', infCity)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение района")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение района', infRajon)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение времени")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение времени', infTime)
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_UNIVERSAL_ACCESS..u8' Авторизация') then
				imgui.BeginChild('##asdasasddf', imgui.ImVec2(750, 60), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Автологин")); imgui.SameLine(); imgui.ToggleButton(u8("Автологин"), autologin)
				if autologin.v then
					imgui.InputText(u8'Пароль', autopass)
				end
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Автогугл")); imgui.SameLine(); imgui.ToggleButton(u8("Автогугл"), autogoogle)
				imgui.SameLine()
				showHelp(u8"При привязки гугл-защиты система вам выдавала ключ, который необходимо сохранить. Введите данный ключ без пробелов и лишних знаков, после чего авторизация будет проходить автоматически.")
				if autogoogle.v then
					imgui.InputText(u8'Секретный код', googlekey)
				end
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_DRUPAL..u8' Таймцикл') then
				if weather.v == -1 then weather.v = readMemory(0xC81320, 1, true) end
				if gametime.v == -1 then gametime.v = readMemory(0xB70153, 1, true) end
				imgui.SliderInt(u8"ID погоды", weather, 0, 50)
				imgui.SliderInt(u8"Игровой час", gametime, 0, 23)
			end
			if imgui.CollapsingHeader(fa.ICON_PAW..u8' Прочие настройки') then
				imgui.SliderInt(fa.ICON_PAW..u8" Коррекция времени", timefix, 0, 5)
			end

			if state and isPlayerSoldier then
				if imgui.Button(fa.ICON_ELLIPSIS_H..u8' Переместить АвтоСтрой', btn_size) then 
					sampAddChatMessage("[Army Assistant]{FFFFFF} Выберите позицию и нажмите {00C2BB}Enter{FFFFFF} чтобы сохранить ее.", 0x046D63)
					win_state['settings'].v = not win_state['settings'].v 
					win_state['main'].v = not win_state['main'].v 
					mouseCoord2 = true 
				end
			end
		elseif showSet == 3 then -- настройки клавиш
			imgui.Columns(2, _, false)
			for k, v in ipairs(tBindList) do
				--[[if isPlayerSoldier then -- выводим клавиши для военного
					if hk.HotKey("##HK" .. k, v, tLastKeys, 100) then
						if not rkeys.isHotKeyDefined(v.v) then
							if rkeys.isHotKeyDefined(tLastKeys.v) then
								rkeys.unRegisterHotKey(tLastKeys.v)
							end
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
						saveSettings(3, "KEY")
					end
					imgui.SameLine()
					imgui.Text(u8(v.text))
				else]]-- -- выводим клавиши для обычной печеньки
					if k ~= 2 and k ~= 8 and k ~= 9 and k ~= 10 then
						if hk.HotKey("##HK" .. k, v, tLastKeys, 100) then
							if not rkeys.isHotKeyDefined(v.v) then
								if rkeys.isHotKeyDefined(tLastKeys.v) then
									rkeys.unRegisterHotKey(tLastKeys.v)
								end
							end
							rkeys.registerHotKey(v.v, true, onHotKey)
							saveSettings(3, "KEY")
						end
						imgui.SameLine()
						imgui.Text(u8(v.text))
					end
				--end
				if k >= 6 and imgui.GetColumnIndex() ~= 1 then imgui.NextColumn() end
			end
		elseif showSet == 4 then -- настройки VK Int.
			if token ~= 1 and vkid2 ~= nil then
				imgui.Columns(2, _, false)
				imgui.Text(u8("Ваш ID ВК: "..tostring((vkid2 == nil and 'N/A' or vkid2))))
				imgui.Text(u8("Статус АФК: "))
				imgui.SameLine()
				if workpause then
					imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"Активно")
				else
					imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Отключено.")
				end
				imgui.SameLine()
				showHelp(u8("Перед тем, как сворачивать игру, если вы хотите, чтобы скрипт работал корректно - вам необходимо активировать статус АФК клавишей VK int, которую вы назначите в настройках. Если вы уйдете в АФК, но не активируете модуль - скрипт выполнит все действия только после выхода из АФК, связано это с тем, что скрипт не могут работать в АФК режиме без включения данного 'рычага'. В момент, пока активен данный режим - чат из игры заблокирован."))
				imgui.Text(u8("Функции не будут работать, если VK Int в статусе - 'Отключено'."))	
				imgui.NewLine()
				imgui.TextWrapped(u8("На некоторых серверах могут возникнуть споры касательно определенных функций, тем не менее, VK Int не дает никакого преимущества игрокам, ибо:"))
				imgui.Text(u8("- Оповещение о ЗП равносильно будильнику."))
				imgui.TextWrapped(u8("- Детект ника всего лишь информирует в основном о выданных наказаниях."))
				imgui.TextWrapped(u8("- Удаленный режим позволяет читать чат, что по факту запретить невозможно."))
					
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Оповещать перед ЗП")); imgui.SameLine(); imgui.ToggleButton(u8'Оповещать перед ЗП', zp)
				imgui.SameLine()
				showHelp(u8("Оповестит сообщением в ВК перед ЗП за 10, 5, 1 минуту, 30 секунд до зарплаты."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Детект вашего ника")); imgui.SameLine(); imgui.ToggleButton(u8'Детект вашего ника', nickdetect)
				imgui.SameLine()
				showHelp(u8("Если в чате появится ваш ник в формате Nick_Name - придет оповещение и строка, в которой вас определило."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать информацию об SMS")); imgui.SameLine(); imgui.ToggleButton(u8'Получать информацию об SMS', smsinfo)
				imgui.SameLine()
				showHelp(u8("Если вам придет СМС или вы его отправите - вам напишет об этом в ВК. Полезно, если отправляете СМС из диалога."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать сообщения из /r, /f")); imgui.SameLine(); imgui.ToggleButton(u8'Получать сообщения из /r, /f', getradio)
				imgui.SameLine()
				showHelp(u8("Отправляет все сообщения из раций, если включена данная опция."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать сообщения из /g")); imgui.SameLine(); imgui.ToggleButton(u8'Получать сообщения из /g', familychat)
				imgui.SameLine()
				showHelp(u8("Отправляет все сообщения из чата семьи/группы."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Удаленный режим")); imgui.SameLine(); imgui.ToggleButton(u8'Удаленный режим', remotev)
				imgui.SameLine()
				showHelp(u8("Позволяет отправлять команды /f(n), /r(n), /sms из личного диалога с сообществом в ВК, который привязан к аккаунту."))
			else
				imgui.Text(u8("К сожалению, функция VK Int. временно недоступна. Попробуйте перезагрузить скрипт или попробовать позже."))
			end
		elseif showSet == 5 then -- меню биндера
			imgui.Columns(4, _, false)
			imgui.NextColumn()
			imgui.NextColumn()
			imgui.NextColumn()
			for k, v in ipairs(mass_bind) do -- выводим все бинды
				imgui.NextColumn()
				if hk.HotKey("##ID" .. k, v, tLastKeys, 100) then -- выводим окошко, куда будем тыкать, чтобы назначить клавишу
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
					end
					rkeys.registerHotKey(v.v, true, onHotKey)
					saveSettings(3, "KEY") -- сохраняем настройки
				end
				imgui.NextColumn()
				if v.cmd ~= "-" then -- условие вывода текста
					imgui.Text(u8("Команда: /"..v.cmd))
				else
					imgui.Text(u8("Команда не назначена"))
				end
				imgui.NextColumn()
				if imgui.Button(fa.ICON_CC..u8(" Редактировать бинд ##"..k)) then imgui.OpenPopup(u8"Установка клавиши ##modal"..k) end
				if k ~= 0 then
					imgui.NextColumn()
					if imgui.Button(fa.ICON_SLIDESHARE..u8(" Удалить бинд ##"..k)) then
						if v.cmd ~= "-" then sampUnregisterChatCommand(v.cmd) print("Разрегистрирована команда /"..v.cmd) end
						if rkeys.isHotKeyDefined(tLastKeys.v) then rkeys.unRegisterHotKey(tLastKeys.v) end
						table.remove(mass_bind, k)
						saveSettings(3, "DROP BIND")
					end
				end
				
				if imgui.BeginPopupModal(u8"Установка клавиши ##modal"..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
					if imgui.Button(fa.ICON_ODNOKLASSNIKI..u8(' Сменить/Назначить команду'), imgui.ImVec2(200, 0)) then
						imgui.OpenPopup(u8"Команда - /"..v.cmd)
					end
					if imgui.Button(fa.ICON_REBEL..u8(' Редактировать содержимое'), imgui.ImVec2(200, 0)) then
						cmd_text.v = u8(v.text):gsub("~", "\n")
						binddelay.v = v.delay
						imgui.OpenPopup(u8'Редактор текста ##second'..k)
					end

					if imgui.BeginPopupModal(u8"Команда - /"..v.cmd, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.Text(u8"Введите название команды, которую хотите применить к бинду, указывайте без '/':")						
						imgui.Text(u8"Чтобы удалить комманду, введите прочерк и сохраните.")						
						imgui.InputText("##FUCKITTIKCUF_1", cmd_name)

						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" Сохранить", imgui.ImVec2(100, 0)) then
							v.cmd = u8:decode(cmd_name.v)

							if u8:decode(cmd_name.v) ~= "-" then
								rcmd(v.cmd, v.text, v.delay)
								print("Зарегистрирована команда /"..v.cmd)
								cmd_name.v = ""
							end
							saveSettings(3, "CMD "..v.cmd)
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_SLACK..u8" Закрыть") then
							cmd_name.v = ""
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end

					if imgui.BeginPopupModal(u8'Редактор текста ##second'..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.BeginChild('##sdaadasdd', imgui.ImVec2(1100, 600), true)
						imgui.Columns(2, _, false)
						--[[imgui.InputInt(u8("Задержка строк(сек.)"), binddelay)
						if binddelay.v <= 0 then
							binddelay.v = 1
						elseif binddelay.v >= 1801 then
							binddelay.v = 1800
						end
						imgui.SameLine()
						showHelp(u8("600 секунд - 10 минут\n1200 секунд - 20 минут\n1800 секунд - 30 минут"))]]--
						imgui.TextWrapped(u8("Параметр {bwait:time} обязателен после каждой строки. Задержка автоматически не выставляется."))
						imgui.TextWrapped(u8"Редактор текста биндера(локальные команды не работают при вызове биндером):")
						imgui.InputTextMultiline('##FUCKITTIKCUF_2', cmd_text, imgui.ImVec2(550, 300))
						
						imgui.Text(u8("Результат:"))
						local example = tags(u8:decode(cmd_text.v))
						imgui.Text(u8(example))
						imgui.NextColumn()
						imgui.BeginChild('##sdaadddasdd', imgui.ImVec2(525, 480), true)
						imgui.TextColoredRGB('• {bwait:1500} {21BDBF}- задержка между строк - {fff555}ОБЯЗАТЕЛЬНЫЙ ПАРАМЕТР')
						imgui.Separator()
						
						imgui.TextColoredRGB('• {params} {21BDBF}- параметр команды - {fff555}/'..v.cmd..' [параметр]')
						imgui.TextColoredRGB('• {paramNickByID} {21BDBF}- цифровой параметр, получаем ник по ID.')
						imgui.TextColoredRGB('• {paramFullNameByID} {21BDBF}- цифровой параметр, получаем РП ник по ID.')
						imgui.TextColoredRGB('• {paramNameByID} {21BDBF}- цифровой параметр, получаем имя по ID.')
						imgui.TextColoredRGB('• {paramSurnameByID} {21BDBF}- цифровой параметр, получаем фамилию по ID.')

						imgui.Separator()
						imgui.TextColoredRGB('• {mynick} {21BDBF}- ваш полный ник - {fff555}'..tostring(userNick))
						imgui.TextColoredRGB('• {myfname} {21BDBF}- ваш РП ник - {fff555}'..tostring(nickName))
						imgui.TextColoredRGB('• {myname} {21BDBF}- ваше имя - {fff555}'..tostring(userNick:gsub("_.*", "")))
						imgui.TextColoredRGB('• {mysurname} {21BDBF}- ваша фамилия - {fff555}'..tostring(userNick:gsub(".*_", "")))
						imgui.TextColoredRGB('• {myid} {21BDBF}- ваш ID - {fff555}'..tostring(myID))
						imgui.TextColoredRGB('• {myhp} {21BDBF}- ваш уровень HP - {fff555}'..tostring(healNew))
						imgui.TextColoredRGB('• {myarm} {21BDBF}- ваш уровень брони - {fff555}'..tostring(armourNew))
						imgui.Separator()
						imgui.TextColoredRGB('• {arm} {21BDBF}- ваша армия - {fff555}'..tostring(fraction))
						imgui.TextColoredRGB('• {org} {21BDBF}- ваша организация - {fff555}'..tostring(org))
						imgui.TextColoredRGB('• {mtag} {21BDBF}- тэг организации - {fff555}'..tostring(mtag))
						imgui.TextColoredRGB('• {rtag} {21BDBF}- ваш тэг - {fff555}'..tostring(u8:decode(rtag.v)))
						imgui.TextColoredRGB('• {myrang} {21BDBF}- ваша должность - {fff555}'..tostring(rang))
						imgui.TextColoredRGB('• {steam} {21BDBF}- ваш спец.отряд(должно быть включено в настройках) - {fff555}'..tostring(u8:decode(spOtr.v)))
						imgui.Separator()
						imgui.TextColoredRGB('• {city} {21BDBF}- город, в котором находитесь - {fff555}'..tostring(playerCity))
						imgui.TextColoredRGB('• {base} {21BDBF}- определение военной зоны - {fff555}'..tostring(ZoneText))
						imgui.TextColoredRGB('• {zone} {21BDBF}- определение района - {fff555}'..tostring(ZoneInGame))
						imgui.TextColoredRGB('• {time} {21BDBF}- МСК время - {fff555}'..string.format(os.date('%H:%M:%S', moscow_time)))
						imgui.Separator()
						if newmark ~= nil then
							imgui.TextColoredRGB('• {targetnick} {21BDBF}- полный ник игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID)))
							imgui.TextColoredRGB('• {targetfname} {21BDBF}- РП ник игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_", " ")))
							imgui.TextColoredRGB('• {tID} {21BDBF}- ID игрока по таргету - {fff555}'..tostring(blipID))
							imgui.TextColoredRGB('• {targetname} {21BDBF}- имя игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_.*", "")))
							imgui.TextColoredRGB('• {targetsurname} {21BDBF}- фамилия игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub(".*_", "")))
						else
							imgui.TextColoredRGB('• {targetnick} {21BDBF}- полный ник игрока по таргету')
							imgui.TextColoredRGB('• {targetfname} {21BDBF}- РП ник игрока по таргету')
							imgui.TextColoredRGB('• {tID} {21BDBF}- ID игрока по таргету')
							imgui.TextColoredRGB('• {targetname} {21BDBF}- имя игрока по таргету')
							imgui.TextColoredRGB('• {targetsurname} {21BDBF}- фамилия игрока по таргету')
						end
						imgui.Separator()
						imgui.TextColoredRGB('• {fid} {21BDBF}- последний ID из /f чата  - {fff555}'..tostring(lastfradioID))
						imgui.TextColoredRGB('• {fidrang} {21BDBF}- звание последнего в /f - {fff555}'..tostring(lastfradiozv))
						imgui.TextColoredRGB('• {fidnick} {21BDBF}- ник последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID)))
						imgui.TextColoredRGB('• {finfname} {21BDBF}- РП имя последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_", " ")))
						imgui.TextColoredRGB('• {fidname} {21BDBF}- имя последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('• {fidsurname} {21BDBF}- фамилия последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub(".*_", " ")))
						imgui.Text("------------------------------------------------------------------------------------------")
						imgui.TextColoredRGB('• {rid} {21BDBF}- последний ID из /r чата - {fff555}'..tostring(lastrradioID))
						imgui.TextColoredRGB('• {ridrang} {21BDBF}- звание последнего в /r - {fff555}'..tostring(lastrradiozv))
						imgui.TextColoredRGB('• {ridnick} {21BDBF}- ник последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID)))
						imgui.TextColoredRGB('• {ridfname} {21BDBF}- РП имя последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_", " ")))
						imgui.TextColoredRGB('• {ridname} {21BDBF}- имя последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('• {ridsurname} {21BDBF}- фамилия последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub(".*_", " ")))

						
						imgui.EndChild()
						imgui.NewLine()
						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" Сохранить", btn_size) then

							v.text = u8:decode(cmd_text.v):gsub("\n", '~')
							v.delay = binddelay.v
							if v.cmd ~= nil then
								rcmd(v.cmd, v.text, v.delay)
							else
								rcmd(nil, v.text, v.delay)
							end
							saveSettings(3, "BIND TEXT")
							imgui.CloseCurrentPopup()
						end

						if imgui.Button(fa.ICON_SLACK..u8" Закрыть не сохраняя", btn_size) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndChild()
						imgui.EndPopup()
					end

					if imgui.Button(fa.ICON_SLACK..u8" Закрыть", imgui.ImVec2(200, 0)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
			end
			
			imgui.NextColumn()
			imgui.NewLine()
			if imgui.Button(fa.ICON_WHEELCHAIR..u8(" Добавить бинд")) then mass_bind[#mass_bind + 1] = {delay = "3", v = {}, text = "n/a", cmd = "-"} end	
		end

		imgui.End()
	end

	if win_state['leaders'].v then -- окно для лидеров
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800, 450), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Лидерам', win_state['leaders'], imgui.WindowFlags.MenuBar)
		if imgui.BeginMenuBar() then
			if imgui.MenuItem(fa.ICON_BARS..u8" Подача новостей") then
				leadSet = 1
			elseif imgui.MenuItem(fa.ICON_PAUSE..u8" Управление организацией") then
				leadSet = 2
			end
			imgui.EndMenuBar()
		end

		if leadSet == 1 then
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 500)
			imgui.Text(u8'Общая госка:')
			imgui.InputText(u8'##gsk1', gos1)
			imgui.InputText(u8'##gsk2', gos2)
			imgui.InputText(u8'##gsk3', gos3)
			imgui.SameLine()
			if imgui.Button(u8'Отправить') then
				if #gos1.v == 0 or #gos2.v == 0 or #gos3.v == 0 then
					sampAddChatMessage("[Army Assistant]{FFFFFF} Минимум одно поле пустое, заполните все поля.", 0x046D63)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." | "..u8:decode(gos1.v))
							wait(1000)
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." | "..u8:decode(gos2.v))
							wait(1000)
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." | "..u8:decode(gos3.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[Army Assistant]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", 0x046D63)
					end
				end
			end
			imgui.Text(u8'Одиночная госка:')
			imgui.InputText(u8'##gsk4', gos4)
			imgui.SameLine()
			if imgui.Button(u8'Отпpавить') then
				if #gos4.v == 00 then 
					sampAddChatMessage("[Army Assistant]{FFFFFF} Поле пустое, подача пустой строки невозможна.", 0x046D63)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." | "..u8:decode(gos4.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[Army Assistant]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", 0x046D63)
					end
				end
			end
			imgui.Text(u8'Окончание:')
			imgui.InputText(u8'##gsk5', gos5)
			imgui.SameLine()
			if imgui.Button(u8'Завершить') then
				if #gos5.v == 0 then
					sampAddChatMessage("[Army Assistant]{FFFFFF} Поле пустое, подача пустой строки невозможна.", 0x046D63)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." | "..u8:decode(gos5.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[Army Assistant]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", 0x046D63)
					end
				end
			end
			--imgui.NewLine()

			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"Время по МСК: ")
			imgui.SameLine()
			imgui.Text(u8(string.format(os.date('%H:%M:%S', moscow_time))))
			imgui.Text(u8'/gnews '..gnewstag.v..' | '..gos1.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' | '..gos2.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' | '..gos3.v)
			imgui.NewLine()
			imgui.Text(u8'/gnews '..gnewstag.v..' | '..gos4.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' | '..gos5.v)
			imgui.NextColumn()
			if imgui.CollapsingHeader(u8'Правительство') then
				if imgui.Button(u8"АП") then
					gos1.v = u8("Сейчас пройдет собеседование в Администрацию Президента.")
					gos2.v = u8("Собеседование будет проходит в здании Администрации.")
					gos3.v = u8("Критерии: 5 лет в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в Администрацию Президента.")
					gos5.v = u8("Собеседование в Администрацию Президента окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия ЛС") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Лос-Сантос.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Лос-Сантос продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Лос-Сантос окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия СФ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Сан-Фиерро.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Сан-Фиерро продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Сан-Фиерро окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия ЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Лас-Вентурас.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Лас-Вентурас продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Лас-Вентурас окончено.")
				end
			end
			if imgui.CollapsingHeader(u8'Министерство Внутренних Дел') then
				if imgui.Button(u8"ЛСПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Лос-Сантос.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Лос-Сантос.")
					gos5.v = u8("Собеседование в полицию г.Лос-Сантос окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"СФПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Сан-Фиерро.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в полицию г.Сан-Фиерро окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ЛВПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Лас-Вентурас.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в полицию г.Лас-Вентурас окончено.")
				end
			end		
			if imgui.CollapsingHeader(u8'Министерство Обороны') then
				if imgui.Button(u8"СВ") then
					gos1.v = u8("Сейчас пройдет призыв в Сухопутные Войска.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Сухопутные Войска.")
					gos5.v = u8("Призыв военкомата в армию Сухопутных Войск завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ВВС") then
					gos1.v = u8("Сейчас пройдет призыв в Военно-Воздушные Силы.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Военно-Воздушные Силы.")
					gos5.v = u8("Призыв военкомата в армию Военно-Воздушных Сил завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ВМФ") then
					gos1.v = u8("Сейчас пройдет призыв в Военно-Морской Флот.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Военно-Морской Флот.")
					gos5.v = u8("Призыв военкомата в армию Военно-Морского Флота завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Ком.Час") then
					gos1.v = u8("Уважаемые жители штата, прошу уделить нам минуточку внимания!")
					gos2.v = u8("С 21:00 до 09:00 на всех военных территориях введен Комендантский час.")
					gos3.v = u8("Военные имеют право открыть огонь на поражение в случае проникновения.")
					gos4.v = ''
					gos5.v = ''
				end
			end		
			if imgui.CollapsingHeader(u8'Министерство Здравоохранения') then
				if imgui.Button(u8"Болька ЛС") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Лос-Сантос.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Лос-Сантос.")
					gos5.v = u8("Собеседование в больницу г.Лос-Сантос завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Болька СФ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Сан-Фиерро.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в больницу г.Сан-Фиерро завершено.")
				end
				imgui.SameLine()			
				if imgui.Button(u8"Болька ЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Лас-Вентурас.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в больницу г.Лас-Вентурас завершено.")
				end
			end
			if imgui.CollapsingHeader(u8'Средства Массовой Информации') then
				if imgui.Button(u8"РЦЛС") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Лос-Сантос проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Лос-Сантос.")
					gos5.v = u8("Собеседование в радиоцентр г.Лос-Сантос завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"РЦСФ") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Сан-Фиерро проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в радиоцентр г.Сан-Фиерро завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"РЦЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Лас-Вентурас проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в радиоцентр г.Лас-Вентурас завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ТВ-Ц") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("Сейчас в Телецентр штата пройдет собеседование!")
					gos3.v = u8("Требования: 4 года в штате, быть законопослушным.")
					gos4.v = u8("Напоминаю, что сейчас проходит собеседование в Телецентр.")
					gos5.v = u8("Собеседование в Телецентр штата окончено.")
				end
			end
			imgui.NewLine()
			if imgui.Button(u8'Очистить строки') then
				gos1.v = ''
				gos2.v = ''
				gos3.v = ''
				gos4.v = ''
				gos5.v = ''
			end
			imgui.NewLine()
			imgui.PushItemWidth(100.0)
			imgui.InputText(u8'Тэг /gnews', gnewstag)
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8("Применить##228")) then saveSettings(4) end
		elseif leadSet == 2 then
			imgui.Text(u8("Данный раздел находится в разработке #2"))
		end
		imgui.End()
	end

	if win_state['help'].v then -- окно "помощь"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(970, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('Помощь'), win_state['help'], imgui.WindowFlags.NoResize)
		imgui.BeginGroup()
		imgui.BeginChild('left pane', imgui.ImVec2(180, 350), true)
		
		if imgui.Selectable(u8"Команды скрипта") then selected2 = 1 end
		imgui.Separator()
		if imgui.Selectable(u8"Шпаргалки") then selected2 = 2 end
		imgui.Separator()	
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##ddddd', imgui.ImVec2(745, 350), true)
		if selected2 == 0 then
			selected2 = 1
		elseif selected2 == 1 then
			imgui.Text(u8"Команды скрипта")
			imgui.Separator()
			imgui.Columns(2, _,false)
			imgui.SetColumnWidth(-1, 300)
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rd [Пост] [Состояние]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/fd [Пост] [Состояние]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/reload")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/where [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/hist [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/сс")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/drone")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ok [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rm")
				if isPlayerSoldier then
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"ПКМ + 1")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"ПКМ + R")
				end
				imgui.Text(u8"Сделать доклад с поста в рацию фракции.")
				imgui.Text(u8"Сделать доклад с поста в общую рацию.")
				imgui.Text(u8"Перезагрузка скрипта.")
				imgui.Text(u8"Запросить местоположение игрока в рацию по его ID.")
				imgui.Text(u8"Проверить историю ников по ID.")
				imgui.Text(u8"Очистка чата.")
				imgui.Text(u8"Получить картинку с дрона на территории.")
				imgui.Text(u8"Удалить метку с игрока.")
				if isPlayerSoldier then
					imgui.Text(u8"Запросить увольнение бойца.")
					imgui.Text(u8"Обновить данные в системе MoD-Helper(ник, фракция).")
					imgui.Text(u8"Отдать честь игроку.")
					imgui.Text(u8"Меню взаимодействия.")
				end
		elseif selected2 == 2 then
			imgui.Text(u8"Шпаргалки")
			imgui.Separator()
			imgui.Text(u8"Сейчас мы рассмотрим работу и возможности шпор, которые интегрированы в скрипт.")
			imgui.TextWrapped(u8"В целом, суть скрипта лежит в названии - это обычные шпаргалки. Вы можете создавать множество шпаргалок с любыми названиями, заполнять их как вашей душе угодно, удалять их в случае ненадобности. Это конечно круто, но этого нам недостаточно, да?")
			imgui.TextWrapped(u8"Шпоры имеют скромный дополнительный функционал, который будет полезен при оформлении ваших вспомогательных текстов. О чем идет речь? Речь идет о поддержке тэгов, а именно:")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"[center], [left], [right].")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"{HTML цвета}.")
			imgui.TextWrapped(u8"Согласитесь, вашему глазу будет приятней с красивым оформлением, нежели монотонным текстом, который словно вот вот задохнется от грусти и печали :D Надеемся, что данная мелочь будет удобна вам в использовании, ну а мы продолжаем перечислять возможности.")
			imgui.TextWrapped(u8"Раньше шпоры можно было использовать для создания собственных лекций в рацию или же при строе, но с приходом внутрескриптового биндера - в этом больше нет необходимости и теперь шпоры выполняют исключительно свою функцию в полной мере, а мы способствуем ее развитию, по этому у нас имеется удобный поиск ключевых фраз по всем созданным шпорам с последующим выводом строчки, где фигурирует ключевая фраза, просто и удобно.")
			imgui.TextWrapped(u8"Собственно на этом и закончилось перечисление особенностей интегрированных шпаргалок, надеемся, они пригодятся вам в использовании и вы будете довольны, приятного пользования.")
		end
		imgui.EndChild()
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['about'].v then -- окно "о скрипте"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(360, 225), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('О скрипте'), win_state['about'], imgui.WindowFlags.NoResize)

		if developMode == 1 then imgui.Text(u8'MoD-Helper | Developer Mode')
		elseif developMode == 2 then imgui.Text(u8'MoD-Helper | Correction Mode')
		else imgui.Text(u8'MoD-Helper') end
		imgui.Text(u8'Разработчик: Shifu Murano.')
		imgui.Text(u8'Версия скрипта: '..thisScript().version)
		imgui.Text(u8'Версия Moonloader: 026')
		imgui.Separator()
		if imgui.Button(u8'VK') then
			print("Открываю: Настройки - О скрипте - ВК")
			sampAddChatMessage("[Army Assistant]{FFFFFF} Сейчас откроется ссылка на официальный паблик ВК.", 0x046D63)
			print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/armyassistant', nil, nil, 1))
		end

		if imgui.Button(u8'Отключить скрипт', btn_size) then 
			offscript = offscript + 1
			if offscript ~= 2 then
				sampAddChatMessage("[Army Assistant]{FFFFFF} Вы собираетесь отключить скрипт, обратная загрузка невозможна без сторонних скриптов или перезахода.", 0x046D63)
				sampAddChatMessage("[Army Assistant]{FFFFFF} Подтвердите отключение скрипта, если уверены в необходимости его отключения.", 0x046D63)
			else
				print("Отключаем скрипт из настроек")
				reloadScript = true
				thisScript():unload()
			end
		end
		imgui.End()
	end

	if win_state['leave'].v then -- окно, которое срабатывает при /leave и просит подтверждения
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(360, 225), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8('Подтверждение самостоятельного увольнения'), win_state['leave'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings) then
			imgui.OpenPopup(u8"Подтверждение /leave")
			if imgui.BeginPopupModal(u8"Подтверждение /leave", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
				imgui.Text(u8("Вы ввели команду для самостоятельного увольнения из фракции, иногда это магическим образом у вас может произойти случайно, на такие случаи создано данное уведомление.\nКоманда была заблокирована в целях безопасности, если вы хотите продолжить - нажмите на кнопку, в ином случае - на другую."))
				if imgui.Button(u8('Я уверен'), btn_size) then
					print("Подвтерждаю скриптовый /leave")
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
					sampSendChat("/leave")
				end
				if imgui.Button(u8('Я передумал'), btn_size) then
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['update'].v then -- окно обновления скрипта
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(450, 200), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('Обновление'), nil, imgui.WindowFlags.NoResize)
		imgui.Text(u8'Обнаружено обновление до версии: '..updatever)
		imgui.Separator()
		imgui.TextWrapped(u8("Для установки обновления необходимо подтверждение пользователя, разработчик настоятельно рекомендует принимать обновления ввиду того, что прошлые версии через определенное время отключаются и более не работают."))
		if imgui.Button(u8'Скачать и установить обновление', btn_size) then
			async_http_request('GET', 'https://raw.githubusercontent.com/SParhutik/MoD-Helper/master/mo.luac', nil, 
				function(response) -- вызовется при успешном выполнении и получении ответа
				local f = assert(io.open(getWorkingDirectory() .. '/mo.luac', 'wb'))
				f:write(response.text)
				f:close()
				sampAddChatMessage("[Army Assistant]{FFFFFF} Обновление успешно, перезагружаем скрипт.", 0x046D63)
				thisScript():reload()
			end,
			function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
				print(err)
				sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка при обновлении, попробуйте позже.", 0x046D63)
				win_state['update'].v = not win_state['update'].v
				return
			end)
		end
		if imgui.Button(u8'Закрыть', btn_size) then win_state['update'].v = not win_state['update'].v end
		imgui.End()
	end

	 if win_state['regst'].v then -- окно регистрации игрока в базе скрипта
	 	imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	 	imgui.SetNextWindowSize(imgui.ImVec2(750, 410), imgui.Cond.FirstUseEver)
         imgui.Begin(u8('Регистрация в системе MoD-Helper'), nil, imgui.WindowFlags.NoResize)
	 	imgui.Text(u8'Приветствуем вас! Вероятней всего вы первый раз проходите процесс регистрации данных, ну начнем.')
	 	imgui.Text(u8'Ваш никнейм: '..userNick..'('..playerAccoutNumber..')')
	 	imgui.Text(u8'Сервер: '..u8(sampGetCurrentServerName())..' ('..srv..')')
	 	imgui.Text(u8('Режим: '..(isPlayerSoldier and 'Военнослужащий' or 'Гражданский'..'.')))
	 	if isPlayerSoldier then
	 		imgui.Text(u8'Фракция: '..tostring(u8(org))..' | '..tostring(u8(preorg))..'('..tostring(u8(arm))..')')
	 		imgui.Text(u8'Должность: '..tostring(u8(rang))..'('..tostring(u8(nasosal_rang))..')')
	 	end

	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"[ВАЖНЫЙ ПУНКТ] Прочтите информацию возле поля ввода тем как завершить регистрацию!")
	 	imgui.InputInt(u8("Ваш ID ВК"), vkid, 0)
	 	imgui.TextWrapped(u8("Указывать необходимо цифровой ID своего ВК, который можете узнать в настройках своего профиля, изменение в дальнейшем будет невозможно, если ID был ранее зарегистрирован - повторная регистрация невозможна. Скрипт будет работать только при условии, что вы подписаны на официальное сообщество разработки, что будет своего рода оплатой за работу, так как проект на данный момент позиционируется как бесплатный."))
	 	if imgui.Button(u8'Открыть сообщество разработки', btn_size) then
	 		sampAddChatMessage("[Army Assistant]{FFFFFF} Сейчас откроется ссылка на официальный паблик ВК.", 0x046D63)
	 		print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/public193828252', nil, nil, 1))
	 	end
	 	imgui.Separator()
	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Если данные не верны или получены не полностью - сообщите разработчику.")
	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Махинации с регистрацией наказываются полным лишением доступа пользователя к скрипту.")
	 	imgui.Separator()
	 	if imgui.Button(u8'Подтвердить данные и зарегистрироваться') then
	 		local regstat = {}
			local rabout = ""
	 		regstat.data = "srv="..srv.."&num="..playerAccoutNumber.."&arm="..arm.."&n="..userNick.."&vkid="..vkid.v.."&sc="..LocalSerial.."&soldier="..tostring(isPlayerSoldier)
	 		regstat.headers = {
	 			['content-type']='application/x-www-form-urlencoded'
	 		}
			
	 		async_http_request('POST', "https://frank09.000webhostapp.com/regst.php", regstat, 
	 			function(response) -- вызовется при успешном выполнении и получении ответа
	 				if u8:decode(response.text):find("Аккаунт зарегистрирован") then
	 					local path = getWorkingDirectory() .. '\\MoD-Helper\\files\\regst.data'
	 					local f = assert(io.open(path, 'wb'))
	 					f:write(vkid.v)
	 					f:close()

	 					sampAddChatMessage("[Army Assistant]{00C2BB} Вы успешно прошли регистрацию в системе MoD-Helper.", 0x046D63)
	 					print("RegInfo: "..u8:decode(response.text))
	 					regStatus = true
	 					win_state['regst'].v = false
	 					sampProcessChatInput("/reload")
	 				elseif u8:decode(response.text):find("Данный аккаунт уже существует") or u8:decode(response.text):find("Не получены данные") then
	 					sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка при регистрации, попробуйте позже.", 0x046D63)
	 					print("RegInfo ErrTrue: "..u8:decode(response.text))
	 					regStatus = true
	 					win_state['regst'].v = not win_state['regst'].v
					end
	 		end,
	 		function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
	 			print(err)
	 			sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка при регистрации, попробуйте позже.", 0x046D63)
	 			win_state['regst'].v = not win_state['regst'].v
	 			regStatus = true
				return
	 		end)

	 	end
	 	imgui.SameLine()
	 	if imgui.Button(u8'Закрыть') then win_state['regst'].v = false thisScript():unload() end
	 	imgui.End()
	 end

	 if win_state['renew'].v then -- окно обновления данных на сервере(делать необходимо в случае смены ника или же организации)
	 	if not doesFileExist(getWorkingDirectory() .. '\\MoD-Helper\\files\\regst.data') then win_state['renew'].v = not win_state['renew'].v sampAddChatMessage("[Army Assistant]{FFFFFF} Вы не можете обновить данные так как вы не были зарегистрированы ранее.", 0x046D63) return false end
	 	imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	 	imgui.SetNextWindowSize(imgui.ImVec2(780, 275), imgui.Cond.FirstUseEver)
         imgui.Begin(u8('Обновление данных в системе MoD-Helper'), nil, imgui.WindowFlags.NoResize)
	 	imgui.TextWrapped(u8'Приветствуем вас! Если вы уже зарегистрированы, но вы перевелись, сменили ник или же вернулись после увольнения - необходимо обновить данные. На данный момент, ваши актуальные данные:')
	 	imgui.Text(u8'Ваш никнейм: '..userNick..'('..playerAccoutNumber..')')
	 	imgui.Text(u8'Сервер: '..u8(sampGetCurrentServerName())..' ('..srv..')')
	 	imgui.Text(u8('Режим: '..(isLocalPlayerSoldier and 'Военнослужащий' or 'Гражданский'..'.')))
	 	if isLocalPlayerSoldier then
	 		imgui.Text(u8'Фракция: '..tostring(u8(org))..' | '..tostring(u8(preorg))..'('..tostring(u8(arm))..')')
	 		imgui.Text(u8'Должность: '..tostring(u8(rang))..'('..tostring(u8(nasosal_rang))..')')
	 	end
	 	imgui.Separator()
	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Если данные не верны или получены не полностью - сообщите разработчику.")
	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Махинации с обновлением данных караются полным лишением доступа пользователя к скрипту.")
	 	imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"После обновления в базе сменится никнейм и организация.")
	 	imgui.Separator()
	 	if imgui.Button(u8'Подтвердить и обновить данные') then
	 		local accupd = {}
	 		accupd.data = "srv="..srv.."&num="..playerAccoutNumber.."&arm="..arm.."&n="..userNick.."&sc="..LocalSerial.."&soldier="..tostring(isLocalPlayerSoldier)
	 		accupd.headers = {
	 			['content-type']='application/x-www-form-urlencoded'
	 		}
			
	 		async_http_request('POST', "https://frank09.000webhostapp.com/st.php", accupd, 
	 			function(response) -- вызовется при успешном выполнении и получении ответа
	 				sampAddChatMessage("[Army Assistant]{00C2BB} Вы успешно обновили свои данные в системе MoD-Helper.", 0x046D63)
	 				print("UpdInfo: "..u8:decode(response.text))
	 				win_state['renew'].v = false
	 				sampProcessChatInput("/reload")
	 		end,
	 		function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
	 			print(err)
	 			sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка при обновлении данных, попробуйте позже.", 0x046D63)
	 			win_state['renew'].v = false
	 			return
	 		end)

	 	end
	 	imgui.SameLine()
	 	if imgui.Button(u8'Закрыть') then win_state['renew'].v = false end
	 	imgui.End()
	 end
	
	if win_state['informer'].v then -- окно информера

		imgui.SetNextWindowPos(imgui.ImVec2(infoX, infoY), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 200), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin("MoD-Service", win_state['informer'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoSavedSettings) then
			imgui.Text("MoD-Helper Services")
			imgui.Separator()
			if not offMask and infMask.v then 
				maskRemainingTime = math.floor((offMaskTime - os.clock() * 1000 ) / 1000)
				maskSeconds = maskRemainingTime % 60
				maskMinutes = math.floor(maskRemainingTime / 60)

				imgui.Text(u8("• Время маски: "..tostring(maskMinutes)..":"..(maskSeconds >= 10 and '' or '0')..""..tostring(maskSeconds)))
				if maskSeconds <= 0 and maskMinutes <= 0 then offMask = true end
			end
			if infZone.v then imgui.Text(u8("• Зона: "..ZoneText)) end
			if infArmour.v then imgui.Text(u8("• Броня: "..armourNew)) end
			if infHP.v then imgui.Text(u8("• Здоровье: "..healNew)) end
			if infCity.v then imgui.Text(u8("• Город: "..playerCity)) end
			if infRajon.v then imgui.Text(u8("• Район: "..ZoneInGame)) end
			
			if infTime.v then imgui.Text(u8("• Время: "..os.date("%H:%M:%S"))) end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['find'].v then -- автострой, который сделан максимально говнокодно, но работает ;D

		imgui.SetNextWindowPos(imgui.ImVec2(infoX2, infoY2), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 170), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8"Автострой", win_state['find'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoSavedSettings) then
			imgui.Columns(3, _, false)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("В строю:"))
			for i = 1, #names do
				imgui.Text(u8(names[i]))
			end

			imgui.NextColumn(2)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("Рядом:"))
			for i = 1, #SecNames do
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames[i].."["..secID[i].."]"))
			end
	
			imgui.NextColumn(3)
			imgui.SetColumnWidth(-1, 160)
			imgui.Text(u8("Не в строю:"))
			for i = 1, #SecNames2 do 
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames2[i].."["..sec2ID[i].."]"))
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if menu_spur.v then -- окно для шпор
		local t_find_text = {}
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1110, 720), imgui.Cond.FirstUseEver)
		imgui.Begin(u8("Шпаргалки | MoD-Helper"), menu_spur)
		imgui.BeginChild(1, imgui.ImVec2(imgui.GetWindowWidth()/3.8, 0), true)
		if imgui.Selectable(u8("Новая шпаргалка")) then add_spur = true end
		imgui.Separator()
		imgui.InputText(u8("Искать"), find_text_spur)
		imgui.Separator()
		
		for i, k in pairs(files) do
			find_name_spur.v = find_name_spur.v:gsub('%[', '')
			find_name_spur.v = find_name_spur.v:gsub('%(', '')
			find_text_spur.v = find_text_spur.v:gsub('%[', '')
			find_text_spur.v = find_text_spur.v:gsub('%(', '')
			if k then
				local nameFileOpen = k:match('(.*).txt')
				if find_text_spur.v:find('%S') then
					local file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r') end
					local fileText = file:read('*a')
					fileText = fileText:gsub('{......}', '')
					if string.rlower(fileText):find(string.rlower(u8:decode(find_text_spur.v))) then
						t_find_text[#t_find_text+1] = k
						if imgui.Selectable(u8(nameFileOpen)) then
							find_text_spur.v = ''
							text_spur = true
							id_spur = i
						end
					else
						text_spur = false
					end
					file:close()
				elseif string.rlower(nameFileOpen):find(string.rlower(u8:decode(find_name_spur.v))) and imgui.Selectable(u8(nameFileOpen)) then
					text_spur = true
					id_spur = i
				end
			end
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild(2, imgui.ImVec2(0, 0), false)
		if add_spur then
			imgui.InputText(u8("Название"), name_add_spur)
			imgui.SameLine()
			imgui.Text("Sym: "..tostring(#name_add_spur.v)..", finded: "..(tostring(name_add_spur.v):match("%s") and "yes" or "no"))
			if imgui.Button(u8("Создать")) then
				math.randomseed(os.time())
				local randf = math.random(1, 999999)

				if #u8:decode(name_add_spur.v) == 0 or tostring(name_add_spur.v):match("%s") then name_add_spur.v = "Unnamed #"..randf end
				name_add_spur.v = u8(removeMagicChar(u8:decode(name_add_spur.v)))
				local namedublicate = false
				-- for i, k in pairs(files) do
				-- 	-- if k == u8:decode(name_add_spur.v) or not u8:decode(name_add_spur.v):find('%S') then namedublicate = true end
				-- 	if k == tostring(u8:decode(name_add_spur.v)) then namedublicate = true end
				-- end
				if doesFileExist("moonloader/MoD-Helper/shpora/"..tostring(u8:decode(name_add_spur.v))..".txt") then
					print("duplicated name in Shpora: "..u8:decode(name_add_spur.v))
					namedublicate = true
					anyvaribleoftext = tostring(u8:decode(name_add_spur.v)..'#'..randf)
				end
					local index, boolindex = 0, false
					while not boolindex do
						index = index + 1
						send = true
						if not files[index] then boolindex = true end
					end

					local file = io.open('moonloader/MoD-Helper/shpora/'..(namedublicate and anyvaribleoftext or u8:decode(name_add_spur.v))..'.txt', 'a')
					file:write('')
					file:flush()
					file:close()
					window_file[#window_file+1] = imgui.ImBool(false)
					files[#files+1] = (namedublicate and anyvaribleoftext or u8:decode(name_add_spur.v))..'.txt'
					add_spur = false
					name_add_spur.v = ''
				-- end
			end
			imgui.SameLine()
			if imgui.Button(u8("Отмена")) then add_spur = false end
		elseif t_find_text[1] then
			for i = 1, #t_find_text do
				local nameFileOpen = t_find_text[i]:match('(.*).txt')
				imgui.BeginChild(i+50, imgui.ImVec2(0, 150), true)
				imgui.AlignTextToFramePadding()
				imgui.Text(u8(nameFileOpen))
				imgui.SameLine()
				if imgui.Button(u8('Открыть шпору ##'..i)) then
					find_text_spur.v = ''
					text_spur = true
					id_spur = i
				end
				imgui.Separator()
				for line in io.lines('moonloader/MoD-Helper/shpora/'..t_find_text[i]) do
					if string.rlower(line):find(string.rlower(u8:decode(find_text_spur.v))) then
						imgui.TextColoredRGB(line, imgui.GetMaxWidthByText(line))
					end
				end
				imgui.EndChild()
			end
		elseif edit_nspur then
			imgui.InputText(u8("Название"), name_edit_spur)
			imgui.SameLine()
			if imgui.Button(u8("Сохранить")) then
				math.randomseed(os.time())
				local randf = math.random(1, 99999)

				if #u8:decode(name_edit_spur.v) == 0 then name_edit_spur.v = "Unnamed #"..randf end
				name_edit_spur.v = u8(removeMagicChar(u8:decode(name_edit_spur.v)))
				local namedublicate = false
				for i, k in pairs(files) do
					if k == u8:decode(name_edit_spur.v) or not u8:decode(name_edit_spur.v):find('%S') then namedublicate = true end
				end
				if not namedublicate then
					local file = io.open('moonloader/moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
					local fileText = file:read('*a')
					file:close()
					os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur])
					local file = io.open('moonloader/MoD-Helper/shpora/'..u8:decode(name_edit_spur.v)..'.txt', 'w')
					file:write(fileText)
					file:flush()
					file:close()
					files[id_spur] = u8:decode(name_edit_spur.v)..'.txt'
					edit_nspur = false
				end
			end
			imgui.SameLine()
			if imgui.Button(u8("Отмена")) then edit_nspur = false end
			imgui.Separator()
			local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
			while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
			local fileText = file:read('*a')
			fileText = fileText:gsub('\n\n', '\n \n')
			imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText))
			file:close()
		elseif id_spur then
			if not window_file[id_spur].v then
				if not text_spur then
					if edit_spur then
						imgui.Text(u8(files[id_spur]:match('(.*).txt')))
						imgui.SameLine()
						if imgui.Button(u8("Сохранить")) then
							edit_text_spur.v = edit_text_spur.v:gsub('\n\n', '\n \n')
							local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'w')
							file:write(u8:decode(edit_text_spur.v))
							file:flush()
							file:close()
							text_spur = true
							edit_spur = false
						end
						imgui.SameLine()
						if imgui.Button(u8("Отмена")) then
							text_spur = true
							edit_spur = false
						end
						imgui.Separator()
						imgui.InputTextMultiline('', edit_text_spur, imgui.ImVec2(-0.1, -0.1))
					end
				else
					local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
					local fileText = file:read('*a')
					fileText = fileText:gsub('\n\n', '\n \n')
					edit_spur = false
					copy_spur = false
					imgui.Text(u8(files[id_spur]:match('(.*).txt')))
					file:close()
					imgui.SameLine()
					if imgui.Button(u8("Изменить")) then
						text_spur = false
						edit_spur = true
						edit_text_spur.v = u8(fileText)
					end
					imgui.SameLine()
					if imgui.Button(u8("Переименовать")) then
						edit_nspur = true
						name_edit_spur.v = u8(files[id_spur]:match('(.*).txt'))
					end
					imgui.SameLine()
					if imgui.Button(u8("Удалить")) then
						os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur])
						while doesFileExist('moonloader/MoD-Helper/shpora/'..files[id_spur]) do os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur]) end
						window_file[id_spur] = nil
						files[id_spur] = nil
						id_spur = nil
						text_spur = false
					end
					imgui.Separator()
					imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText))
				end
			end
		end
		imgui.EndChild()
		imgui.End()
	end

	for i, k in pairs(files) do
		if k then
			if window_file[i].v then
				local flags = (not imgui.ShowCursor) and imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize or 0
				imgui.SetNextWindowPos(imgui.ImVec2(x/2-100, y/2-100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
				imgui.Begin(u8(k:match('(.*).txt')), window_file[i], flags)
				local file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r')
				while not file do file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r') end
				local fileText = file:read('*a')

				imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText) - 15)
			
				file:close()
				imgui.End()
			end
		end
	end
end

function rcmd(cmd, text, delay) -- функция для биндера, без которой не будет ни команд, ни клавиш.
	if cmd ~= nil then -- обрабатываем биндер, который работает по команде
		if cmd ~= '-' then sampUnregisterChatCommand(cmd) end -- делаем это для перерегистрации команд
		sampRegisterChatCommand(cmd, function(params) -- регистрируем команду + задаем функцию
			globalcmd = lua_thread.create(function() -- поток гасим в переменную, чтобы потом я мог стопить бинды, но что-то пошло не так и они обратно не запускались ;D
				if not keystatus then -- проверяем, не активен ли сейчас иной бинд
					cmdparams = params -- задаем параметры тэгам
					if text:find("{param") and cmdparams == '' then -- если в тексте бинда есть намек на тэг параметра и параметр пуст, говорим заполнить его
						--sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /"..cmd.." ["..(text:find("byID}") and 'ID' or 'Параметр').."].", 0x046D63)
						local partype = '' -- объявим локальную переменную
						if text:find("ByID}") then partype = "ID" else partype = "Параметр" end -- зададим ей значение из условия
						sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /"..cmd.." ["..partype.."].", 0x046D63)
					else
						keystatus = true
						local strings = split(text, '~', false) -- обрабатываем текст бинда
						for i, g in ipairs(strings) do -- начинаем непосредественный вывод текста по строкам
							if not g:find("{bwait:") then sampSendChat(tags(tostring(g))) end
							wait(g:match("%{bwait:(%d+)%}"))
						end
						keystatus = false
						cmdparams = nil -- обнуляем параметры после использования
					end
				end
			end)
		end)
	else
		-- тут все аналогично, как и с командами, только чуток проще.
		globalkey = lua_thread.create(function()
			if text:find("{params}") then
				sampAddChatMessage("[Army Assistant]{FFFFFF} В данном бинде установлен параметр, использование клавишами невозможно.", 0x046D63)
			else

				local strings = split(text, '~', false)
				keystatus = true
				for i, g in ipairs(strings) do
					if not g:find("{bwait:") then sampSendChat(tags(tostring(g))) end
					wait(g:match("%{bwait:(%d+)%}"))
				end
				keystatus = false
			end
		end)
	end
end

function split(str, delim, plain) -- функция фипа, которая сделала биндер рабочим
    local tokens, pos, plain = {}, 1, not (plain == false) 
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function showHelp(param) -- "вопросик" для скрипта
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(param)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function all_trim(s) -- удаление пробелов из строки ес не ошибаюсь
   return s:match( "^%s*(.-)%s*$" )
end

function ClearChat() -- очистка чата
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function ClearBlip() -- удаление маркера/таргета
	if newmark ~= nil then
		if marker.v then
			removeBlip(newmark)	
			print("Снимаем таргет маркер с игрока "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[Army Assistant]{FFFFFF} Маркер с игрока "..sampGetPlayerNickname(blipID).." был успешно удален.", 0x046D63)
		else
			print("Снимаем таргет с игрока "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[Army Assistant]{FFFFFF} Таргет с игрока "..sampGetPlayerNickname(blipID).." был успешно снят.", 0x046D63)
		end
		blipID = nil
		newmark = nil
	end
end


function ARGBtoRGB(color) return bit32 or require'bit'.band(color, 0xFFFFFF) end -- конверт цветов

function rel() -- перезагрузка скрипта
	sampAddChatMessage("[Army Assistant]{FFFFFF} Скрипт перезагружается.", 0x046D63)
	reloadScript = true
	thisScript():reload()
end

function clearSeleListBool(var) -- не ебу что-это ахахах ;D
	for i = 1, #SeleList do
		SeleListBool[i].v = false
	end
	SeleListBool[var].v = true
end

 function registration() -- проверяем наличие регистрации игрока в базе скрипта, получаем информацию из базы.
 	print("Проверяем регистрацию игрока..")
 	local path = getWorkingDirectory() .. '\\MoD-Helper\\files\\regst.data'
 	if not doesFileExist(path) then
 		print("Локальный файл подтверждения не найден, открываем регистрацию.")
 		win_state['regst'].v = not win_state['regst'].v
 		regStatus = true
 		gmsg = true
 	else
 		print("Регистрация ранее была пройдена, получаем данные.")
 		local getstat = {}
 		getstat.data = "srv="..srv.."&num="..playerAccoutNumber
 		getstat.headers = {
 			['content-type']='application/x-www-form-urlencoded'
 		}
		async_http_request('POST', 'https://frank09.000webhostapp.com/gfile.php', getstat, -- получение данных статистики с сервера
 		function(response) -- вызовется при успешном выполнении и получении ответа
 			if not response.text:find("Не получены данные.") then
 				if not response.text:find("Такого аккаунта нет") then
 					if not response.text:find("| %d+ | %d+ | %d+ | %d+ | %d+ | %d+ | %d+ | .* | %d+ | %d+ | %d+ | %d+ | .*") then
 						print("GetInfo error #1: "..u8:decode(response.text))
						sampAddChatMessage("[Army Assistant]{FFFFFF} Не удалось получить статистику игрока с базы данных. Свяжитесь с разработчиком.", 0x046D63)
 						sampAddChatMessage("[Army Assistant]{FFFFFF} Скрипт активен в ограниченном режиме, активация {00C2BB}/mod{FFFFFF}. Разработчик: {00C2BB}Shifu Murano.", 0x046D63)
 						sampAddChatMessage("[Army Assistant]{FFFFFF} Технический модератор и просто хороший человек - {00C2BB}Arina Borisova.", 0x046D63)
 						if userNick == "Shifu_Murano" then
 							sampAddChatMessage("[MoD-Admin]{00C2BB} Доступ разработчика подтвержден, функционал расширен.", 0x046D63)
 							developMode = 1
 							nasosal_rang = 1
 						end
 						pentcout, pentsrv, pentinv, pentuv = 0
 						activated = false
 						accessD = u8("Нет допуска")
						gmsg = true
					else				
						superID, getarm, vigcout, narcout, dostupLvl, rAbout, whitelist, developMode, order, vkid2, soldier = response.text:match("| (%d+) | %d+ | %d+ | (%d+) | (%d+) | (%d+) | (%d+) | (.*) | (%d+) | (%d+) | (%d+) | (%d+) | (.*)")
 						local vkc = io.open(path, 'r')
 						vkinf = vkc:read('*a')
 						vkc:close()	
						
						print("GetStat result - ID: "..tostring(superID)..", mode: "..developMode..", SVKID:"..tostring(vkid2))
 						print("Local VKID: "..vkinf..", server VKID: "..tostring(vkid2))

 						if vkid2 == vkinf then
 							print("GetStat: VKinf == VKID")
 							vigcout = tonumber(vigcout) -- получение выговоров
 							narcout = tonumber(narcout) -- получение нарядов
 							order = tonumber(order) -- получение наград
							dostupLvl = tonumber(dostupLvl) -- получение уровня доступа
 							whitelist = tonumber(whitelist) -- получение уровня доступа
 							developMode = tonumber(developMode) -- получение уровня доступа

 							if developMode == 4 then 
 								sampAddChatMessage("[Army Assistant]{FFFFFF} Работа скрипта была приостановлена для вашего аккаунта.", 0x046D63)
 								sampAddChatMessage("[Army Assistant]{FFFFFF} Более подробней можете уточнить в группе разработки.", 0x046D63)
 								reloadScript = true
 								thisScript():unload()
								return
 							end
 							sampAddChatMessage("[Army Assistant]{FFFFFF} Ваш ID в базе: {00C2BB}"..tonumber(superID).."{FFFFFF}, активация {00C2BB}/mod{FFFFFF}, разработчик: {00C2BB}Shifu Murano.", 0x046D63)
 							sampAddChatMessage("[Army Assistant]{FFFFFF} Технический модератор и просто хороший человек - {00C2BB}Arina Borisova.", 0x046D63)
 							if dostupLvl == 0 then accessD = u8("1 уровень допуска")
 							elseif dostupLvl == 1 then accessD = u8("2 уровень допуска")
							elseif dostupLvl == 2 then accessD = u8("3 уровень допуска")
 							elseif dostupLvl == 3 then accessD = u8("Alfa допуск")
							else accessD = u8("Нет допуска") end
							activated = true
							if soldier:find("true") then
							sampAddChatMessage("[Army Assistant]{FFFFFF} Вы определены как {00C2BB}военный{FFFFFF}, функционал откорректирован.", 0x046D63)
 								isPlayerSoldier = true
 							else
 								sampAddChatMessage("[Army Assistant]{FFFFFF} Вы определены как {00C2BB}гражданский{FFFFFF}, функционал откорректирован.", 0x046D63)
 								isPlayerSoldier = false
 							end
							if developMode == 1 then
 								sampAddChatMessage("[MoD-Admin]{00C2BB} Доступ разработчика подтвержден, функционал расширен.", 0x046D63)
								nasosal_rang = 10
 							elseif developMode == 2 then
 								sampAddChatMessage("[Army Assistant]{00C2BB} Технические изменения от разработчика подтверждены, функционал откорректирован.", 0x046D63)
 							end
 							while token == 0 do wait(0) end
 							if vkinf ~= nil then checkVK(vkinf) else print("VK check error") end
 							gmsg = true
 						else
 							print("GetStat: VKinf ~= VKID")
 							sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка, локальный и серверный ID ВКонтакте по вашим данным не совпадают.", 0x046D63)
 							sampAddChatMessage("[Army Assistant]{FFFFFF} Работа скрипта невозможна, если вы не подписаны на группу разработки или же указали неверный VK ID.", 0x046D63)
 							reloadScript = true
 							thisScript():unload()
 						end
 					end
 				else
 					sampAddChatMessage("[Army Assistant]{FFFFFF} Произошла ошибка, данный аккаунт не зарегистрирован в базе данных MoD-Helper.", 0x046D63)
 					sampAddChatMessage("[Army Assistant]{FFFFFF} Работа скрипта остановлена, свяжитесь с разработчиком для устранения проблемы.", 0x046D63)
 					reloadScript = true
 					thisScript():unload()
 				end
 			else
 				sampAddChatMessage("[Army Assistant]{FFFFFF} Не удалось получить статистику игрока с базы данных. Свяжитесь с разработчиком.", 0x046D63)
 				sampAddChatMessage("[Army Assistant]{FFFFFF} Скрипт активен в ограниченном режиме, активация {00C2BB}/mod{FFFFFF}. Разработчик: {00C2BB}Shifu Murano.", 0x046D63)
 				if userNick == "Shifu_Murano" then
 					sampAddChatMessage("[MoD-Admin]{00C2BB} Доступ разработчика подтвержден, функционал расширен.", 0x046D63)
 					developMode = 1
 					nasosal_rang = 1
 				end
				
 				print("GetStat error #1: "..u8:decode(response.text))
 				pentcout, pentsrv, pentinv, pentuv = 0
 				activated = false
 				accessD = u8("Нет допуска")
 				gmsg = true
 			end
 		end,
 		function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
 			print(err)
 			sampAddChatMessage("[Army Assistant]{FFFFFF} База данных времененно недоступна, попробуйте повторить операцию позже.", 0x046D63)
 			sampAddChatMessage("[Army Assistant]{FFFFFF} Свяжитесь с технической поддержкой или попробуйте повторить позднее.", 0x046D63)
 			sampAddChatMessage("[Army Assistant]{FFFFFF} Скрипт активен в ограниченном режиме, активация {00C2BB}/mod{FFFFFF}. Разработчик: {00C2BB}Shifu Murano.", 0x046D63)
 			sampAddChatMessage("[Army Assistant]{FFFFFF} Технический модератор и просто хороший человек - {00C2BB}Arina Borisova.", 0x046D63)
 			if userNick == "Shifu_Murano" then
 				sampAddChatMessage("[MoD-Admin]{00C2BB} Доступ разработчика подтвержден, функционал расширен.", 0x046D63)
 				developMode = 1
 				nasosal_rang = 1
 			end
 			pentcout, pentsrv, pentinv, pentuv = 0
 			activated = false
 			accessD = u8("Нет допуска")
 			gmsg = true
 		end)
 		regStatus = true
 	end
 end

function update() -- проверка обновлений
	local zapros = https.request("https://raw.githubusercontent.com/SParhutik/MoD-Helper/master/update.json")

	if zapros ~= nil then
		local info2 = decodeJson(zapros)

		if info2.latest_number ~= nil and info2.latest ~= nil and info2.drop ~= nil then
			updatever = info2.latest
			version = tonumber(info2.latest_number)
			dropver = tonumber(info2.drop)
			
			print("[Update] Начинаем контроль версий")
			
			if tonumber(thisScript().version_num) <= dropver then
				print("[Update] Used non supported version: "..thisScript().version_num..", actual: "..version)
				sampAddChatMessage("[Army Assistant]{FFFFFF} Ваша версия более не поддерживается разработчиком, работа скрипта невозможна.", 0x046D63)
				reloadScript = true
				thisScript():unload()
			elseif version > tonumber(thisScript().version_num) then
				print("[Update] Обнаружено обновление")
				sampAddChatMessage("[Army Assistant]{FFFFFF} Обнаружено обновление до версии "..updatever..".", 0x046D63)
				win_state['update'].v = true
				UpdateNahuy = true
			else
				print("[Update] Новых обновлений нет, контроль версий пройден")
				if checkupd then
					sampAddChatMessage("[Army Assistant]{FFFFFF} У вас стоит актуальная версия скрипта: "..thisScript().version..".", 0x046D63)
					sampAddChatMessage("[Army Assistant]{FFFFFF} Необходимости обновлять скрипт - нет, приятного пользования.", 0x046D63)
					checkupd = false
				end
				UpdateNahuy = true
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Ошибка при получении информации об обновлении.", 0x046D63)
			print("[Update] JSON file read error")
			UpdateNahuy = true
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Не удалось проверить наличие обновлений, попробуйте позже.", 0x046D63)
		UpdateNahuy = true
	end
end

function cmd_color() -- функция получения цвета строки, хз зачем она мне, но когда то юзал
	local text, prefix, color, pcolor = sampGetChatString(99)
	sampAddChatMessage(string.format("Цвет последней строки чата - {934054}[%d] (скопирован в буфер обмена)",color),-1)
	setClipboardText(color)
end

function async_http_request(method, url, args, resolve, reject) -- асинхронные запросы, опасная штука местами, ибо при определенном использовании игра может улететь в аут ;D
	local request_lane = lanes.gen('*', {package = {path = package.path, cpath = package.cpath}}, function()
		local requests = require 'requests'
        local ok, result = pcall(requests.request, method, url, args)
        if ok then
            result.json, result.xml = nil, nil -- cannot be passed through a lane
            return true, result
        else
            return false, result -- return error
        end
    end)
    if not reject then reject = function() end end
    lua_thread.create(function()
        local lh = request_lane()
        while true do
            local status = lh.status
            if status == 'done' then
                local ok, result = lh[1], lh[2]
                if ok then resolve(result) else reject(result) end
                return
            elseif status == 'error' then
                return reject(lh[1])
            elseif status == 'killed' or status == 'cancelled' then
                return reject(status)
            end
            wait(0)
        end
    end)
end
-- function async_http_request(method, url, args, resolve, reject) -- effil
-- 	local request_thread = effil.thread(function (method, url, args)
-- 	   local requests = require 'requests'
-- 	   local result, response = pcall(requests.request, method, url, args)
-- 	   if result then
-- 		  response.json, response.xml = nil, nil
-- 		  return true, response
-- 	   else
-- 		  return false, response
-- 	   end
-- 	end)(method, url, args)
-- 	-- Если запрос без функций обработки ответа и ошибок.
-- 	if not resolve then resolve = function() end end
-- 	if not reject then reject = function() end end
-- 	-- Проверка выполнения потока
-- 	lua_thread.create(function()
-- 	   local runner = request_thread
-- 	   while true do
-- 		  local status, err = runner:status()
-- 		  if not err then
-- 			 if status == 'completed' then
-- 				local result, response = runner:get()
-- 				if result then
-- 				   resolve(response)
-- 				else
-- 				   reject(response)
-- 				end
-- 				return
-- 			 elseif status == 'canceled' then
-- 				return reject(status)
-- 			 end
-- 		  else
-- 			 return reject(err)
-- 		  end
-- 		  wait(0)
-- 	   end
-- 	end)
--  end

function changeSkin(id, skinId) -- визуальная смена скина(imring вроде бы скидывал ее)
    bs = raknetNewBitStream()
    if id == -1 then _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) end
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, skinId)
    raknetEmulRpcReceiveBitStream(153, bs)
    raknetDeleteBitStream(bs)
end

function ex_find() -- Отыгровка финда
	sampSendChat("/find")
	lua_thread.create(function()
		if rpFind.v then
			sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК из кармана и "..(lady.v and 'открыла' or 'открыл').." список бойцов "..(arm == 3 and 'флота' or 'армии'))
			wait(800)
			sampSendChat("/do КПК "..(findCout ~= nil and 'показал информацию, количество бойцов '..(arm == 3 and 'флота' or 'армии')..': '..findCout or 'скрыл информацию о количестве бойцов '..(arm == 3 and 'флота' or 'армии')..'')..".")
			wait(800)
			sampSendChat("/me после ознакомления со списком "..(lady.v and 'закрыла' or 'закрыл').." и "..(lady.v and 'положила' or 'положил').." КПК обратно")				
		end
	end)
end

function sampev.onSendPlayerSync(data)
	if workpause then -- костыль для работы скрипта при свернутой игре
		return false
	end
end

function sampev.onServerMessage(color, text)

	WriteLog(os.date('[%H:%M:%S | %d.%m.%Y]')..' '..text:gsub("{.-}", ""),  'MoD-Helper', 'chatlog') -- запись всех сообщений в лог, тут я подрезал функцию у Вани Мытарева хД
	
	if ads.v then -- отключаем объявки и переносим их в консольку
		if color == 13369599 and text:find("Отправил") then print("{14ccbd}[ADS]{279c40}".. text) return false end
		if color == 10027263 and text:find("сотрудник") then print("{14ccbd}[ADS]{0f6922}"..text) return false end
	end

	if text == "Вы сняли маску" or text == "Вы надели новую маску и выбросили старую" then -- таймер маски АРП, автора не помню, имеются неточности с подсчетом +- 30 секунд(но это не точно).
		offMask = true
	elseif color == 865730559 and text:find("Ваше месторасположение на GPS скрыто") then
		offMaskTime = os.clock() * 1000 + 600000
		offMask = false
	end

	-- if nickdetect.v and workpause and text:find(userNick) then -- детект ника и отправка сообщения в ВК при включенном VK-Int.
	-- 	vkmessage(tonumber(vkid2), "Ваш ник обнаружен в сообщении:%0A"..text:gsub("{.-}", "")) -- %0A - это перенос на новую строку, именно так его понимает ВК.
	-- end

	-- if familychat.v and workpause and text:match("%[G%] .*") then -- получение сообщений из /g чата при включенном VK-Int.
	-- 	vkmessage(tonumber(vkid2), text)
	-- end

	if color == 1721355519 and text:match("%[F%] .*") then -- получение ранга и ID игрока, который последним написал в /f чат, для тэгов биндера
		lastfradiozv, lastfradioID = text:match('%[F%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	elseif color == 869033727 and text:match("%[R%] .*") then -- получение ранга и ID игрока, который последним написал в /r чат, для тэгов биндера
		lastrradiozv, lastrradioID = text:match('%[R%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	end

	-- if getradio.v and workpause then -- получение /r, /f чатов при включенном VK-Int
	-- 	if color == 1721355519 and text:find("[F]") then
	-- 		vkmessage(tonumber(vkid2), text)
	-- 	elseif color == 869033727 and text:find("[R]") then
	-- 		vkmessage(tonumber(vkid2), text)
	-- 	end
	-- end

	if color == -577699841 and text:find("взял%(а%)") then -- автоматическая хавка в военной столовке
		if text:find("паёк") or text:find("добавкой") or text:find("десерт") then
			lua_thread.create(function()
				wait(500)
				sampSendChat("/eat")
			end)
		end
		return {color, text}
	end

	if text:match("SMS: .* | Отправитель: .* %[т%.%d+%]") then -- сохраняем входящий номер + отыгровки мобилки + звук
		local tsms, tname, SMS = text:match("SMS: (.*) | Отправитель: (.*) %[т%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		if inComingSMS.v then
			if phoneModel.v == '' then
				sampSendChat(string.format("/do На телефон пришло сообщение с номера %d.", SMS))
			else
				sampSendChat(string.format("/do На телефон модели %s пришло сообщение с номера %d.", u8:decode(phoneModel.v), SMS))
			end
			sampAddChatMessage(text, 0xFFFF00)
		end
		if smssound.v then bass.BASS_ChannelPlay(asms, false) end
		lastnumberon = SMS 
	end
		
	if text:match("SMS: .* | Получатель: .* %[т%.%d+%]") then -- сохраняем исходящий номер
		local SMSfor = text:match("SMS: .* | Получатель: .* %[т%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		lastnumberfor = SMSfor 
	end

	if color == 1721355519 and text:find("%[P.E.S.%]: Передаю координаты:") then -- принимаем коорды из пса, если видим в /f чате
		if text:find("%d+E%d+Z%d+") then
			tempx, tempy, tempz = text:match("(%d+)E(%d+)Z(%d+)")
			if tonumber(tempx) < 10000 and tonumber(tempy) < 10000 and tonumber(tempz) < 200 then
				sampAddChatMessage("1", -1)
				tempx = tempx - 3000
				tempy = tempy - 3000
				tempz = tempz - 1
			else
				tempx = nil
				tempy = nil
				tempz = nil
			end
			if tempx ~= nil and tempy ~= nil and tempz ~= nil then
				x1 = tempx
				y1 = tempy
				z1 = tempz
				lastcall = 1
			end  
		end
	end

	if text:find('%[.+%]%s.+%s%a+_%a+%[.+%]: .+') then -- покраска ников в /r, /f чатах
		local developers = { ['Shifu_Murano'] = true, ['Arina_Borisova'] = true, ['Milana_Fiorentino'] = true, ['Vasiliy_Rostov'] = true }
		local chats = { ['[F]'] = true, ['[R]'] = true, ['[T]'] = true }
		local zvans = { ['Генерал'] = true, ['Адмирал'] = true, ['Полковник'] = true, ['Подполковник'] = true, ['Капитан 1 ранга'] = true, ['Капитан 2 ранга'] = true }

		local chat, zvan, nick, id, text2 = text:match('(%[.+%])%s(.+)%s(%a+_%a+)%[(%d+)%]: (.+)')
	
		if chats[chat] and not developers[nick] and getServerColored:find(nick) then
			return { color, chat..' '..zvan..' {d1ae1f}'..nick..'['..id..']: {'..string.format('%X', bit.rshift(color, 8))..'}'..text2 }
		elseif chats[chat] and developers[nick] then
			return { color, chat..' '..zvan..' {d11f1f}'..nick..'['..id..']: {'..string.format('%X', bit.rshift(color, 8))..'}'..text2 }
		end
	end
end

function load_settings() -- загрузка настроек
	-- CONFIG CREATE/LOAD
	ini = inicfg.load(SET, getGameDirectory()..'\\moonloader\\config\\MoD-Helper\\settings.ini')
	
	-- LOAD CONFIG INFO
	
	gangzones = imgui.ImBool(ini.settings.gangzones)
	zones = imgui.ImBool(ini.settings.zones)
	rpFind = imgui.ImBool(ini.settings.rpFind)
	rptime = imgui.ImBool(ini.settings.rptime)
	assistant = imgui.ImBool(ini.settings.assistant)
	
	autologin = imgui.ImBool(ini.settings.autologin)
	autogoogle = imgui.ImBool(ini.settings.autogoogle)
	googlekey = imgui.ImBuffer(u8(ini.settings.googlekey), 256)
	autopass = imgui.ImBuffer(u8(ini.settings.autopass), 256)
	gnewstag = imgui.ImBuffer(u8(ini.settings.gnewstag), 20)
	
	timefix = imgui.ImInt(ini.settings.timefix)
	localskin = imgui.ImInt(ini.settings.skin)
	enableskin = imgui.ImBool(ini.settings.enableskin)


	rpinv = imgui.ImBool(ini.settings.rpinv)
	rprang = imgui.ImBool(ini.settings.rprang)
	rpuninvoff = imgui.ImBool(ini.settings.rpuninvoff)
	rpskin = imgui.ImBool(ini.settings.rpskin)
	rpuninv = imgui.ImBool(ini.settings.rpuninv)

	infZone = imgui.ImBool(ini.informer.zone)
	infHP = imgui.ImBool(ini.informer.hp)
	infArmour = imgui.ImBool(ini.informer.armour)
	infCity = imgui.ImBool(ini.informer.city)
	infKv = imgui.ImBool(ini.informer.kv)
	infTime = imgui.ImBool(ini.informer.time)
	infRajon = imgui.ImBool(ini.informer.rajon)
	infMask = imgui.ImBool(ini.informer.mask)

	screenSave = imgui.ImBool(ini.settings.screenSave)
	rpblack = imgui.ImBool(ini.settings.rpblack)
	smssound = imgui.ImBool(ini.settings.smssound)
	keyT = imgui.ImBool(ini.settings.keyT)
	marker = imgui.ImBool(ini.settings.marker)
	ads = imgui.ImBool(ini.settings.ads)
	inComingSMS = imgui.ImBool(ini.settings.inComingSMS)
	specUd = imgui.ImBool(ini.settings.specUd)
	chatInfo = imgui.ImBool(ini.settings.chatInfo)
	armOn = imgui.ImBool(ini.settings.armOn)
	timecout = imgui.ImBool(ini.settings.timecout)
	rtag = imgui.ImBuffer(u8(ini.settings.tag), 256)
	zp = imgui.ImBool(ini.vkint.zp)
	nickdetect = imgui.ImBool(ini.vkint.nickdetect)
	pushv = imgui.ImBool(ini.vkint.pushv)
	smsinfo = imgui.ImBool(ini.vkint.smsinfo)
	remotev = imgui.ImBool(ini.vkint.remotev)
	getradio = imgui.ImBool(ini.vkint.getradio)
	familychat = imgui.ImBool(ini.vkint.familychat)
	enable_tag = imgui.ImBool(ini.settings.enable_tag)
	gos1 = imgui.ImBuffer(u8(ini.settings.gos1), 256)
	gos2 = imgui.ImBuffer(u8(ini.settings.gos2), 256)
	gos3 = imgui.ImBuffer(u8(ini.settings.gos3), 256)
	gos4 = imgui.ImBuffer(u8(ini.settings.gos4), 256)
	gos5 = imgui.ImBuffer(u8(ini.settings.gos5), 256)
	
	timerp = imgui.ImBuffer(u8(ini.settings.timerp), 256)
	timeBrand = imgui.ImBuffer(u8(ini.settings.timeBrand), 256)
	phoneModel = imgui.ImBuffer(u8(ini.settings.phoneModel), 256)
	spOtr = imgui.ImBuffer(u8(ini.settings.spOtr), 256)
	lady = imgui.ImBool(ini.settings.lady)
	timeToZp = imgui.ImBool(ini.settings.timeToZp)
	gateOn = imgui.ImBool(ini.settings.gateOn)
	lockCar = imgui.ImBool(ini.settings.lockCar)
	strobesOn = imgui.ImBool(ini.settings.strobes)
	infoX = ini.settings.infoX
	infoY = ini.settings.infoY
	infoX2 = ini.settings.infoX2
	infoY2 = ini.settings.infoY2
	findX = ini.settings.findX
	findY = ini.settings.findY
	asX = ini.assistant.asX
	asY = ini.assistant.asY
	-- END CONFIG WORKING
end

function cmd_histid(params) -- история ников по ID
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) or myID == tonumber(params) then
			local histnick = sampGetPlayerNickname(params)
			sampAddChatMessage("[Army Assistant]{FFFFFF} Проверяем историю ников игрока "..histnick..".", 0x046D63)
			sampSendChat("/history "..histnick)
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу.", 0x046D63)
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /hist [ID].", 0x046D63)
	end
end

function rradio(params) -- обработка /r
	if mtag ~= "M" then -- запрещаем министру обороны /r чат
		if #params:match("^.*") > 0 then
			local params = params:match("^(.*)")
			if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
				params = params:gsub("%(", "")
				params = params:gsub("%)", "")
				sampAddChatMessage("[Army Assistant]{FFFFFF} Сообщение определено как OOC и автоматически обработано. Запрещенные символы: %( и %).", 0x046D63)
				sampSendChat(string.format("/r (( %s ))", params))
			else
				if rtag.v == '' then
					sampSendChat(string.format("/r %s", params))
				else
					sampSendChat(string.format("/r %s: %s", u8:decode(rtag.v), params))
				end
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /r [text].", 0x046D63)	
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Вам недоступна данная рация.", 0x046D63)
	end
end

function fradio(params) -- обработка /f
	if #params:match("^.*") > 0 then
		local params = tostring(params:match("^(.*)"))
		if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
			params = params:gsub("%(", "")
			params = params:gsub("%)", "")
			sampAddChatMessage("[Army Assistant]{FFFFFF} Сообщение определено как OOC и автоматически обработано. Запрещенные символы: %( и %).", 0x046D63)
			sampSendChat(string.format("/f (( %s ))", params))
		else 
			if mtag == "M" then
				sampSendChat(string.format("/f %s", params))
			else
				if rtag.v == '' then
					sampSendChat(string.format("/f %s", params))
				else
					sampSendChat(string.format("/f %s: %s", u8:decode(rtag.v), params))
				end
			end
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /f [text].", 0x046D63)
	end
end

function cmd_livby(params) -- просьба увала
	if isPlayerSoldier then
		if nasosal_rang <= 4 and nasosal_rang ~= 10 and nasosal_rang ~= 8 and nasosal_rang ~= 8 then sampAddChatMessage("[Army Assistant]{FFFFFF} Данная команда доступна с 5 по 7 ранг.", 0x046D63) return end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r Запрашиваю отставку бойца %s#%d.", livname, livid))
					sampSendChat(string.format("/r Причина: %s", rsn))
				else
					sampSendChat(string.format("/r [%s]: Запрашиваю отставку бойца %s#%d.", u8:decode(rtag.v), livname, livid))
					sampSendChat(string.format("/r [%s]: Причина: %s", u8:decode(rtag.v), rsn))
				end
			else
				sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", 0x046D63)
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /liv [ID] [Причина].", 0x046D63)
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Недоступно на данном сервере или вы не военнослужащий.", 0x046D63)
	end
end

function ex_uninvite(params) -- увал из организации
	if isPlayerSoldier then
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpuninv.v then
						sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'зашла' or 'зашел').." в базу данных военнослужащих")
						wait(1000)
						sampSendChat(string.format("/me "..(lady.v and 'отметила' or 'отметил').." личное дело %s как «Уволен»", uname))
						wait(250)

						if rtag.v == '' then
							sampSendChat(string.format("/f Боец %s был отправлен в отставку.", mtag, uname))
							wait(500)
							sampSendChat(string.format("/f Причина отставки: %s", ureason))
						else
							sampSendChat(string.format("/f %s: Боец %s был отправлен в отставку.", u8:decode(rtag.v), uname))
							wait(500)
							sampSendChat(string.format("/f %s: Причина отставки: %s", u8:decode(rtag.v), ureason))
						end
					end
					wait(250)
					sampSendChat(string.format("/uninvite %d %s", uid, ureason))
				end)
			else
				sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", 0x046D63)
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /uninvite [ID] [Причина].", 0x046D63)
		end
	else
		sampSendChat("/uninvite "..params)
	end
end

function ex_uninviteoff(params) -- увал в оффе
	if isPlayerSoldier then
		if params:match("^%S+%s.*") then
			local uid, ureason = params:match("^(%S+)%s(.*)")	
			local uname = uid:gsub('_', ' ')
			lua_thread.create(function()
				if rpuninvoff.v then
					sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'вошла' or 'зашел').." в базу данных военнослужащих")
					wait(1000)
					sampSendChat(string.format("/me "..(lady.v and 'отметила' or 'пометил').." личное дело %s как «Уволен»", uname))
					wait(250)

					if rtag.v == '' then
						sampSendChat(string.format("/f Боец %s был отправлен в отставку.", uname))
						wait(500)
						sampSendChat(string.format("/f Причина отставки: %s", ureason))
					else
						sampSendChat(string.format("/f %s: Боец %s был отправлен в отставку.", u8:decode(rtag.v), uname))
						wait(500)
						sampSendChat(string.format("/f %s: Причина отставки: %s", u8:decode(rtag.v), ureason))
					end
				end
				sampSendChat(string.format("/uninviteoff %s %s", uid, ureason))
			end)
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /uninviteoff [Ник] [Причина].", 0x046D63)
		end
	else
		sampSendChat("/uninviteoff "..params)
	end
end

function ex_skin(params) -- смена скина
	if isPlayerSoldier then
		if params:match("^%d+") then
			local uid = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) or myID == tonumber(params) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpskin.v then
						sampSendChat("/do В руках заранее подготовленный комплект с формой.")
						wait(1000)						
						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." пакет с формой для %s", uname))
						wait(500)
					end
					sampSendChat(string.format("/changeskin %d", uid))
				end)
			else
				sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу.", 0x046D63)
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /changeskin [ID].", 0x046D63)
		end
	else
		sampSendChat("/changeskin "..params)
	end
end

function ex_rang(params) -- повышение ранга
	if isPlayerSoldier then
		if params:match("^%d+%s%d+%s.*") then
			local uid, rcout, utype = params:match("^(%d+)%s(%d+)%s(.*)")
			rcout = tonumber(rcout)
			if sampIsPlayerConnected(uid) then
				lua_thread.create(function()
					if rcout <= 0 or rcout >= 5 then sampAddChatMessage("[Army Assistant]{FFFFFF} Ограничение на количество повышения от 1 до 4.", 0x046D63) return end
					if rprang.v then
						local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
						sampSendChat("/do Сумка с новыми погонами в руке.")
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and 'открыла' or 'открыл').." сумку с погонами и "..(lady.v and 'достала' or 'достал').." нужные для %s", uname))
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." новые погоны %s", uname))
						wait(500)
						sampSendChat("/anim 21")
					end
					
					if utype == "+" then
						for i = 1, rcout do
							sampSendChat(string.format("/rang %s +", uid))
							wait(700)
						end
					elseif utype == "-" then
						for i = 1, rcout do
							sampSendChat(string.format("/rang %s -", uid))
							wait(700)
						end
					else
						if rprang.v then
							sampSendChat("/me понял, что что-то пошло не так")
							wait(1500)
							sampSendChat("Дико извиняюсь, я малость заработался..")
						else
							sampAddChatMessage("[Army Assistant]{FFFFFF} Вы ввели неверный тип [+/-].", 0x046D63) return
						end
					end
				end)
			else
				sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", 0x046D63)
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /rang [ID] [Количество] [+/-].", 0x046D63)
		end
	else
		sampSendChat("/rang "..params)
	end
end

function ex_invite(params) -- инвайты игроков
	if isPlayerSoldier then
		if params:match("^%d+") then
			local uid, utype = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpinv.v then
						if arm == 3 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Navy.")
						elseif arm == 1 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Ground Force.")
						elseif arm == 2 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Air Force.")
						end
						wait(1000)

						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." пакет новобранцу по имени %s", uname))
						wait(1000)

						sampSendChat(string.format("%s, переодевайтесь, рацию на пояс.", uname))
						wait(1500)
						sampSendChat("На портале штата Вы обязаны ознакомиться с уставом и реформами.")
						wait(100)
					end
					sampSendChat(string.format("/invite %d", uid))
				end)
			else
				sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", 0x046D63)
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /invite [ID].", 0x046D63)
		end
	else
		sampSendChat("/invite "..params)
	end
end

function cmd_where(params) -- запрос местоположения
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) then
			local name = string.gsub(sampGetPlayerNickname(params), "_", " ")
			if rtag.v == '' then
				sampSendChat(string.format("/r %s, доложите свое местоположение. На ответ 10 секунд.", name))
			else
				sampSendChat(string.format("/r [%s]: %s, доложите свое местоположение. На ответ 10 секунд.", u8:decode(rtag.v), name))
			end
		else
			sampAddChatMessage("[Army Assistant]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", 0x046D63)
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /where [ID].", 0x046D63)
	end
end

function addGangZone(id, left, up, right, down, color) -- создание гангзоны
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteFloat(bs, left)
    raknetBitStreamWriteFloat(bs, up)
    raknetBitStreamWriteFloat(bs, right)
    raknetBitStreamWriteFloat(bs, down)
    raknetBitStreamWriteInt32(bs, color)
    raknetEmulRpcReceiveBitStream(108, bs)
    raknetDeleteBitStream(bs)
end

function removeGangZone(id) -- удаление гангзоны
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetEmulRpcReceiveBitStream(120, bs)
    raknetDeleteBitStream(bs)
end

function showInputHelp() -- chatinfo(для меня) и showinputhelp от хомяка ес не ошибаюсь
	while true do
		local chat = sampIsChatInputActive()
		if chat == true then
			local in1 = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			fib = in3 + 48
			fib2 = in2 + 10
			local _, mmyID = sampGetPlayerIdByCharHandle(PLAYER_PED)
			local nname = sampGetPlayerNickname(mmyID)
			local score = sampGetPlayerScore(mmyID)
			local color = sampGetPlayerColor(mmyID)
			local capsState = ffi.C.GetKeyState(20)
			local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
			local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
			local localName = ffi.string(LocalInfo)
			local text = string.format(
				"%s :: {%0.6x}%s[%d] {ffffff}:: Капс: %s {FFFFFF}:: Язык: {ffeeaa}%s{ffffff}",
				os.date("%H:%M:%S"), bit.band(color,0xffffff), nname, mmyID, getStrByState(capsState), string.match(localName, "([^%(]*)")
			)
			
			if chatInfo.v and sampIsLocalPlayerSpawned() and nname ~= nil then renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF) end
			end
		wait(0)
	end
end

function getStrByState(keyState) -- состояние клавиш для chatinfo
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end

function reconnect() -- реконнект игрока
	lua_thread.create(function()
		sampSetGamestate(5)
		sampDisconnectWithReason()
		wait(18000) 
		sampSetGamestate(1)
	end)
end


function random_messages() -- рандомные сообщения
	lua_thread.create(function()
		local messages = {
			{ "Прежде всего помните - вы солдат, помните свою роль и быть может играть станет интересней.", "Не забывайте про субординацию и устав армии, приятной игры." },
			{ "Если вам понравилась задумка скрипта, но вам чего то не хватает, есть выход!", "Свяжитесь с разработчиком, предложите свою идею, помогите в развитии :)" },
			{ "В случае возникновения каких либо проблем со скриптом - обратитесь к разработчику.", "Мы стараемся делать работу со скриптом приятной и комфортной для своих пользователей." },
			{ "Разработчик скрипта выступают против биндерботства и деградации.", "В связи с этим мы используем только незначительные отыгровки, которые никак не влияют на РП процесс." },
			{ "Участились случаи похищений в нелюдных местах от псевдо агентов ФБР.", "Если вы видите таких - фрапсите и старайтесь уйти от них любой ценой, кроме суицида/оффа, это наказывается." },
			{ "Если вы заметили грубое нарушение от сослуживца - не нужно молчать.", "Нужно бороться с несоблюдением правил и субординации, помогите нам, внесите свой вклад!" },
			{ "Ты считаешь, что достоин большего? Ты считаешь, что тебя должны уважать? Ты правда хочешь этого?", "Поднимайте по карьерной лестнице в Мин.Обороны, занимай высокие должности и пробивай свои преграды, как будто их нет!" },
			{ "Если вы заметили ЧС или подозрительную активность рядом с военными объектами - сообщите!", "Ведь именно ваше сообщение может предупредить сослуживцев о возможной стычке с врагами!"},
			{ "Помните, при использовании летной техники необходимо соблюдать безопасную от пуль высоту и уметь маневрировать!", "Помимо этого, если вы за штурвалом Apache или Hydra - не применяйте вооружение без приказа высшего командования!" },
			{ "При использовании рации - будьте адекватны, не оскорбляйте и не провоцируйте людей.", "Если вы хотите покинуть ряды армии - не флудите об этом, быть может вас никто физически не может уволить." },
			{ "Всегда носите бронежилет, держите при себе патроны и металл, ведь именно они могут вас спасти." }
		}
		while true do
			math.randomseed(os.time())
			wait(300000)
			for _, v in pairs(messages[math.random(1, #messages)]) do
				sampAddChatMessage("[Army Assistant]{FFFFFF} "..v, 0x046D63)
			end
			wait(3000000)
		end
	end)
end

function cmd_rd(params) -- доклады в /r чат
	if params:match("^.*%s.*") then		
		local post, sost = params:match("^(.*)%s(.*)")
		sampSendChat("/r "..(rtag.v ~= '' and '['..u8:decode(rtag.v)..']' or '').." Докладываю, пост: "..post.." | Состояние: "..sost)

		if screenSave.v then
			lua_thread.create(function()
				sampSendChat((srv <= 9 and '/time' or '/time'))
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /rd [Пост] [Состояние].", 0x046D63)
	end
end

function cmd_fd(params) -- доклады в /f чат
	if params:match("^.*%s.*") then
		local post, sost = params:match("^(.*)%s(.*)")
		if rtag.v == '' then
			sampSendChat(string.format("/f Докладываю, пост: %s | Состояние: %s", post, sost))
		else
			sampSendChat(string.format("/f %s: Докладываю, пост: %s | Состояние: %s", u8:decode(rtag.v), post, sost))
		end
		if screenSave.v then
			lua_thread.create(function()
				sampSendChat("/time")
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[Army Assistant]{FFFFFF} Используйте: /fd [Пост] [Состояние].", 0x046D63)
	end
end

function format_file() --запись чсников в таблицу
	blackbase = {}
	for line in io.lines(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") do
		name, reason = line:match("(%a+_?%a+)(.+)")
		temp = {name, reason}
		table.insert(blackbase, temp)
	end
end

function drone() -- дрон/камхак, дополнение камхака санька
	lua_thread.create(function()
		if droneActive then
			sampAddChatMessage("[Army Assistant]{FFFFFF} На данный момент вы уже управляете дроном.", 0x046D63)
			return
		end
		sampAddChatMessage("[Army Assistant]{FFFFFF} Управление дроном клавишами: {00C2BB}W, A, S, D, Space, Shift{FFFFFF}.", 0x046D63)
		sampAddChatMessage("[Army Assistant]{FFFFFF} Режимы дрона: {00C2BB}Numpad1, Numpad2, Numpad3{FFFFFF}.", 0x046D63)
		sampAddChatMessage("[Army Assistant]{FFFFFF} Скорость полета дрона: {00C2BB}+(быстрей), -(медленней){FFFFFF}.", 0x046D63)
		sampAddChatMessage("[Army Assistant]{FFFFFF} Заверешить пилотирование дроном можно клавишей {00C2BB}Enter{FFFFFF}.", 0x046D63)
		while true do
			wait(0)
			if flymode == 0 then
				droneActive = true
				posX, posY, posZ = getCharCoordinates(playerPed)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angY = 0.0
				flymode = 1
			end
			if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
				offMouX, offMouY = getPcMouseMovement()  
				offMouX = offMouX / 4.0
				offMouY = offMouY / 4.0
				angZ = angZ + offMouX
				angY = angY + offMouY
				
				if angZ > 360.0 then angZ = angZ - 360.0 end
				if angZ < 0.0 then angZ = angZ + 360.0 end
		
				if angY > 89.0 then angY = 89.0 end
				if angY < -89.0  then angY = -89.0 end   

				if isKeyDown(VK_W) then      
					radZ = math.rad(angZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed  
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				if isKeyDown(VK_S) then  
					curZ = angZ + 180.0
					curY = angY * -1.0      
					radZ = math.rad(curZ) 
					radY = math.rad(curY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed                       
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
		
				if isKeyDown(VK_A) then  
					curZ = angZ - 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)     
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)       
		
				if isKeyDown(VK_D) then  
					curZ = angZ + 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)   
		
				if isKeyDown(VK_SPACE) then  
					posZ = posZ + speed      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)
				
				if isKeyDown(VK_SHIFT) then  
					posZ = posZ - speed
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2) 
			
				if isKeyDown(187) then 
					speed = speed + 0.01
				end 
				if isKeyDown(189) then
					speed = speed - 0.01
					if speed < 0.01 then speed = 0.01 end
				end
				if isKeyDown(VK_NUMPAD1) then
					setInfraredVision(true)
				end
				if isKeyDown(VK_NUMPAD2) then
					setNightVision(true)
				end
				if isKeyDown(VK_NUMPAD3) then
					setInfraredVision(false)
					setNightVision(false)
				end
				if isKeyDown(VK_RETURN) then
					setInfraredVision(false)
					setNightVision(false)
					restoreCameraJumpcut()
					setCameraBehindPlayer()
					flymode = 0
					droneActive = false
					break
				end
			end
		end
	end)
end

-- ФУНКЦИИ ИЗ ШПОРЫ
function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then
			output = output .. russian_characters[ch + 32]
		elseif ch == 168 then
			output = output .. russian_characters[184]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function string.rupper(s)
	s = s:upper()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:upper()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 224 and ch <= 255 then
			output = output .. russian_characters[ch - 32]
		elseif ch == 184 then
			output = output .. russian_characters[168]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end

	render_text(string)
end

function removeMagicChar(text)
	for i = 1, #magicChar do text = text:gsub(magicChar[i], '') end
	return text
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end

function getFilesSpur()
	local files, window_file = {}, {}
	local handleFile, nameFile = findFirstFile('moonloader/MoD-Helper/shpora/*.txt')
	while nameFile do
		if handleFile then
			if not nameFile then 
				findClose(handleFile)
			else
				window_file[#window_file+1] = imgui.ImBool(false)
				files[#files+1] = nameFile
				nameFile = findNextFile(handleFile)
			end
		end
	end
	return files, window_file
end

JLeYBxvRA2eDCYh6nBEv5mfKGPNn = "x-hVJ3rNnaZH?GA#ESF*#^mG-EWPsVHhMd&8Ud#9zVz7r#U2zve=Zx9f6?WuY?syRvUzwnu_5jnJ@C6qtHTG!%t34dTJMCS3k-py4eRjN2YGB+7UdbwEKS$5+TKY-qp3+umEW7DNrE?&h&D4mB3cv-AQ=!-tGd_3r4a3Q8Uu5=BSEyeKVn#9@rL2PA?d*y6qMMAz47Cwx@346bsPULwDaRpP4?ETr!^XzxHXh-hExyPnDNBexgdGYSvwHwJ-H7Lw44h@r*h9kpL8@BezMA36cKJrs#W%gbaXxHnUMY3-jJdeKHu+z5q#D7-VZ!#JJ3CxMPwVWf$dumKRvqLQRjUZtEJgjy_egY^LdcM5dWQLP8a*JAtJwTRVw*$t_Wzxxsd+b+4#pZAFc%*mGhRBne#KdEz6x_eT$p7WWBwhy6SQqbQFzR8tRF*&YMx*=guZ36URy9@fNqs9Ss9^TNZrdPwEZLQ_m9=b7V&z$crXS^e?z*=n!*A^LR27qmb?VT_$!86+5%XKVTbGJ!rGjdhMLWa&7SWPpy_geu-QL^uQzqy84yvd6!#Q?z-7hU*5?9fpwbyg7xMWMxWGBWbac*uaQzWz6$*WVf*&gY?%-c@7tH?nYkzQdd^?YUaLn*zq6GvkhPjm6fp?N3QLERv@5V9*NTnNpuJPS?@Mc3m*#qEQZtX9xrBKN+N6!63%Pmh@UP&XA-5eQK_8TB?f9g6v&Dc+%n7%tcHLs7cHsTHfFtr%ZcV3QvqGTDLbDjRYHw*3M#P9fkL*G57aUcXvK@aV_p6Uc3KWDQcRcS&&NwG#_a8wQj#6xYn^A@zG^*e_tRR9RWY?&hRwr3^H9y7gQZr#m_ZnbrhBKUNJs?PHGk9!ugHUnr7qAXjpq$2wwUe_BjdNLrwtKzf6C4YY!8KU&7Yvw^M=QsTdgT8jsX@X@fM-pBjwS@vw?C@EHEnWv+9VQ*6hY6pwZgbu%MTdWK9FxA**+5uS2jJZm2$XxEpXuXFQVA!$FVDpb@jQ#Mz6$LVj-chE@gA?ZmtKMz2KaaFD552Xe#tE9bTX5%xqHCp*$ydkH2J8ucBQmDDwZDz^m-@REcRgkX9z4JMnLMBCkL-?V93@WS+n*bTq!-89Bfy+mF??Uy7RYLEmt!Mg$5L=&aBxwryh5cV5wnXpue4mG_Q?g6W=xV5xP+@xmDMgsBChQjaWjTY_%*L^tKysLjJnz=4C##_gz5p=T$TA3#yBy&ZXYU$LFY4c?kgqWXLVS%dV+kp!XvWKp5gzy@#caDK6JZChGW?6!FBGKerk-@E#ny6_%?EjGLdYuKn!3wTY&zu$XQCtF%UqMc&Kk+*rjtnbV9H$n?Tx5uXrbNBm!rEtJUub2MEP&L%tu!PZF=&%D_r=B_GzEQS%Kz^!EYapczQG3_Pj#*h+D@txatnStfwTmVF3*CHcL&nq_xGGQcTYxR9zHr&m2$gUg-v64PqAgp-ncUvPvqG_PM5YC8EJPp^GV&%Y8QP$jGvH9&PQBJx%b*mVRN5gEs7ZrW7pJn8ge=rY3VDwk@8%RQg=!cKW==C&V@#Cf#mcLB%vtm!s&8y?9R+zj2$t5cr#bR#K@qw^k=#dTVf#44LLywdJepF_M@d&5#5*atZ!!grD-tmK_7jE-#udfvG4r#9CZ+z6+$Hch_DGnT6T3^!HByfu48fh&Ac%t!*m4_H*pLy8PaM$TEJTts9mT9SdT9!V6uyFZP?CnA&@7ww&N+Vf=CCp4#qk+BAPz^g!fnUqSSU5zr^3dgELx_XWBnbsLeX$xs^=b?!Er&HQQKY&SnLxg6j3cZbA3G%j?WrKFbk6q^ZkTmqTJjfu38X^hdRNvFZSpE+tV+4pH6!phm=&nP$cG?t^ZXvTLTrJF^CHV8H#-uWxzU#%+dwG#6r7Y5YCYPUvdyE8d-tX$f$@@EZAT$vzpJyZqP_r^%pryk@%-U_qFsc?Jztd%2Qu8W-3MKk9atygs7R9n*4+29*+_SQ_7vAmY&$nyzb*QhKx$nWuwhPMeS=GeT^r2kxsw#b?btLt4pj+S-tfYHzVH+8eCWhS8w3nJYc9AC!%"
KGd6r35fZhsFvb3xpWVZddmT3XP6B2 = "Pswyp2!7%_HCnpWn8%$EgunCkx=82W24t4T$GvWGRVby3_s5Ve5fM9nfZ338bTHf-x2vLs%NcA@S63$v#MJ@=-h*YwgArbU+jYHha&z?Q$5GM!jxE8RDHdveHS@-twZ2dnYRp+rUF+Xy5y4#c^m6j8fgkwQZRfLnAhcZ5-ZnYXzxshkqVLJE2WA-5RXN$ZTXhQv=-e#aT2K_w@u83mr*3bKgxBdg_CUukP4APQ#gbFuUkMbN3rQkGgVMeV2NHB5k_u?HtmP#g$pmnxP%GA*qz4F!D=-Hjk5ud7vMVbYVx$gvVp^b-82BNsDmqN%9N*GEc6yw9478NG3_FN!vky?TV6Pw5A6w$5HeA8uVzbymFyekhu=*9eWj+UZQaJP7Zbqwz%kr#TE7Nnt$+vEjUgbpUMPgA6SpkrZcrhL?J?#MPsWY7Zj%6H*k5unDUBu894J7zrsxrjL+CN9ypzhZvNwuydTrpcwt_Q9bmpSdbh9z2dSVh-frxryMQXD5++SZzqDdJnwt_E#?GM_dgSSk#+3WvPxMD&MhdUZWaysCYH8AdejwqR!3XU=NETDXYvU26dKtvM4qwNpgbGUM&uq%naeh!cLvKzb!sz5umR=pV@G6tmA@UYa5Pd#ucmbGvtQKqgG8Z2kvyWXUsK-4%VTzm-VF_+u@&WvZ@xQcP$G2MVf#NJT5DUK22bnZGvcz*k8=EJ9CZ3BpDpP$bzGh8SA+C67fF@XvXZM=qn_$n*TFTKf@njLufK+TdH&Nuv7CU4Yx_!LRF&5=&#9x?P*kvXk=N8&xRj%W^nkP5ga#pMKEyEZCT^_V@FYX-ZC-tDHN!#vb32RawDwnjb_XGvp?5zY9+2SHh^C=KfS#Amjb3_JSN$?BTrXMZ-_RbXuM=_fCKCYStNUAZh_udTM+f7ZvU3HdR2KYf+-?*Muw86KAAkQ7F_3g4agQ+D8J#VzsV?3tH$nAkfEf+BFG9LzYhZnf^TE2cPAyZMzt2Vt&Pd2mDEd4L$xD+bgxV%!K6Z3jc4sR3RKQ?eYS?h&%2wk#HaWgMfzbG5=DM_nh8tUg5y#Fr9Yk2STAa&%YK7LXJn@prF=y-VKx8uYN?h-hYTrs^%HauPT3W?eAyDfm4&KNPy5$yZd&vpq5_Cqvn$uf&3F&Q+GFrjKp9-kU#XUxfxT7_=tASZ&mLTX!2*Ne^Ly_D3&mXv$=9=dHb!-j98v@tS6+#Ce$#hXy=RjAnFKyRSQnD!XH7LtB82JU7ak^shWeaudbC32Cmn_Lc47__&F%8FE#V-5ZWZN4*45!bSEM6?+h6LE-Q+Gw95$qy#5#!yvRe#bGpyh=H*Je@eDh@qX3qsXqvnZ34pqeYcAvMMM^gz&W=r!$*x=sWasEyxuXKXDny3tvJ5R@mp_LNn8bQWC*H@nshXy@p^Krm6KCbtat8PQjUTu+Srxd3qwxMaTBNswSYvw_CS%%ZUA?xvZDZgaWXBxET7?Hw8@8E9VQ^GU=MwH$^hypeBsgPuE3#Pj%xJD7@b!7qxVqQFF5fUZtP4PhXn^WVM*L-q@Lz$qrQ377_vhQn4282qhQtKF6D@7KXZ_NmAKFEhfMg?7+gjGk_V?ThNYF-%G#$evfdAQpDK!&qm6zZNYURDqjD%xgj=a7xk^M6FJ6&#^=f5*PVCh_cTRjSNG?QxMETLqxjk*gFwbE7k?%#eaauXK3aGupVNfH8@7#b8!sm%Y55EqhX$*9+%CYv22gU=LcaMaE4r9b7nsT7j%yTjuhXSstGKuzh2SdVX@LP?%PfSekvb%MWbk^W5Q^$hw=L!@CCZn-fNFXVx&@DS2&#FAwHAWND&DfKY6de2uH@r?qA=C3Qz@WnspStqwUDZa=L-WXg&^-uR23f5gX84+%8MjNb?Tat^F+GLye^J4#K-W4KyBa9yANA?hCv?W^^ntYq5Q#5-jS#3P-cdXa#c77+hTs^t%b_WA8w8H!tbS_maY_TVb9_-cHQTQcr9WjxDcn?GxREVLt^RXJ&U*@s5vzXDLRJ%LVFRFaf$4mqtftWY&Mw=^Chpn5=8LnaJez6NbTe%-9Fq&YyCtJ"
QuyuqWJXUGXUmE84uxestL5unKxyF = "Q_&JQVpX#6f4WhYQpRQzEMfyyZx35cgN8SbnRALEGDwMW%c4yEvqd_TSwzJ4t7qRVdWG3C65=7uqbsA75gs7rzy48^wnd+m67mN*73M=U44S6B+9H56dN$NsGNe?pE3?*hSS39X#5Dk*ep9j%4QGVLUQ6&K2-=kQ*qr@7FbnFuTYez^w7VktKNqWXC@6gtfUD9B=aKf$6B*vds8sbwj=DuS!J+^R&Rp!#t4sUhFMGWhH9b-e*4+T5J%SF?kf4tm_=t6tt7b%XfJ-BFT#++Uks#=-MS3R-8#xT=J5ZguJ$ER!nqnc-j5tjphsS^atG=Zx@Uz+q=CTuju&cu5FjCMfhEVF^Y#Y3#j9GB4^g=CdXa-e9ts_$SM*a+Vzj-h7Vt!W!@a*Cz$KX6j@v-v_qhnD^!auGu!e6QTq@=jNzcYJc+SVGFQY%+=NS38cBrkRAe8Zt+9m=X=6n@@PyDGg+wd^^w3*V%gB?JLDA9eKk!RrPe?4gQkTu7s%stE^X=KDtBYh@BYUcgEbzFg7&vfrTScdxDbL&Jj2#KYG9yF3tT_r#qUg?S+gc#!J^qDbpDt3&Zkk_t5bj3MMfka$b$_QR4D6*uw7ePwQaZgm#q?k!KV^Re52Tx%KXXK=Bq3m*8*xmrAXKGNuF?#ykeL#y#YkZX@@%7T&T?gabA@wwnHnmC?Xrz!2&3CK$F+EMyB4%4k*NdeWya3?*T!*BVw5bXF2qSp=_WAvWWzqzbn&55U8Nm5gm_n5U8C+ny@#W?xuMfj+#aEvHyeC57hnLAMreKa!U$RyWafdCNwRfzNTLvSXdD?xA4uB=DdZV6dPQnTVppkV3rvvcrj5cKnF=MT!MmXUWV#664cvwysuUCtXzS%hbp*p8*9E=9FEp!-d_2D9AC3q%2Q29qucq&KgMF_W-a2bK+MBFQJB%gZ5t@a!DN74Ku3-vnJpA4J7u#vqjm?X^aZasauRHH#qauR#D9+$?cR98KZKT8_V546&CBT7sJgpgbjyFBkc4WzwP$ChR_-Mvb+U9@uDEUY2GT_kv$dTh#nEP#BFKCA#NEQM6wfymCmfD%&sGR=&qk7TNZ%3k+Z85HfdP&Y&Bd@4bhuF5g@QG8DsFdLhkKCN9zvL$ZHWzk*gbsw#6A@!pSPEvQYahPKXWQGMzuDSNzatxSn4RmzfkDmme*?UNe8Zh%f+FaH+NHZJ5mpY&xN4-6UuuRyhEAx@bH535mS=vpw&5T5fgt^5G8TptBMw_M_CRC!^FfCeeT2EF^AJf#yvnZjLy&-x=F3%?kEx*64S2YXa46g5#hP9tQEKJUjUC9e8REH?MukkW7b2A-dSWgbsP%5ZBynwx?-GwFrzQM$fV+ZrACx6?xV*?v!pw8pgBNg#$U3p*?W7%WfgKUSjEnPz?#cFJW$?S$uTYm4TcQk+^5Y_g2_2eFW7eTgCCyr@5&r=Y7r9=Q&xrD-&GP2vM=Lg*Ew+XmuqJX$tJBYV8_zD$%xTMN_dzXz%yv&LJ4Wds8@*rV45b7FQ87mTd==%y4wYxTk#UxGga2jKe5t*N?8P?+c*J64BLJWVPeA4p?cG4%3!uDtxTBgKLAKj%FN9rHWQ*RD!!pQ*CkU@*NTmU_#MaW#QsdLn9xVC2Cj8gnVFhq9uagu2Rm&wFXG5AWsyZ+jdk#V&ZH?+xAq7Pwr^hM-j%ywLgjYn_K$E_m?EgdHk=zu%*j+je+sZCh$335umCq4d2=YGpLEBK@QsVpf!vcvEc%#4Dt!LN6%r7&3^9vPtf#2guh9GHB@fHvV%d=kPY5+94$zCWMHkR*cBerTe4*ezXqfB5*z@=%NDcZDx%n6q7--5gj8Wz-L*EW8TYxq!k?^7$mVDj*R^px&qab+8SVJeL3^M6$LWcg_*Jx9%xmRJLRL3ZAPBKH&W#g*_&rsg&mvKp&ZvFd2&Zy$gS+RsM*U4TDcE+qFeqQvA3M!hLAEp_?rdS5#$UegkjwNX+vntQWq_T_RjvbH%ZaLsVb!8@FR7$?G8_fM!2Vvd_=k@3NPnYst2acC4jzGAaFkBXFaDAs9^4vth$QsXEjpKZPh222jE"