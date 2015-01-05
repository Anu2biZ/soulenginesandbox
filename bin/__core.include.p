<?

function getParams( $j = -1 ){
if( $j == -1 )
for( $i = 0; $i < $i + 1; $i++ ){
if( param_str($i) == NULL )
break;
$params[$i] = param_str($i);
}
else
$params = param_str($j);
return $params;
}

function replaceSl($s){return str_replace("\\","/",$s);}
function replaceSr($s){return str_replace("/","\\",$s);}


function pre($obj){
	
	if ( sync(__FUNCTION__, func_get_args()) ) return;
	
	$s = print_r($obj,true);
	gui_message($s);
}


global $progDir, $moduleDir, $engineDir, $_c, $APPLICATION;

define('DOC_ROOT', replaceSl($progDir));
define('MODULE_DIR',replaceSl($moduleDir));
define('ENGINE_DIR',replaceSl($engineDir));
define('DRIVE_CHAR', $progDir[0]);

define('progDir',$progDir);
set_include_path(DOC_ROOT);



/* %START_MODULES% */
//=======================================================//
class myVars {
    
    static function set($var, $name){
        
        $GLOBALS[$name] = $var;
    }
    
    static function set2(&$var, $name){
        $GLOBALS[$name] =& $var;
    }
    
    static function get($name){
        
        if (isset($GLOBALS[$name]))
            return $GLOBALS[$name];
        else
            return false;
    }
}

class TConstantList{
	
	public $defines;
	
	function __set($nm,$val){
	    if (!defined($nm)){
	    $this->defines[$nm] = $val;
		define($nm,$val, false);
	    }
	}
	
	function __get($nm){
	 
	    return $this->defines[$nm];   
	}
	
	function setConstList($names,$beg = 1){
		for($i=0;$i<count($names);$i++){
		    if (! defined($names[$i]) ){
			define($names[$i],$i+$beg, false);
			$this->defines[$names[$i]] = $i+$beg;
		    }
		}
	}
}

class app {

    static function hide(){
        if ( sync('app::hide') ) return;
        
        application_minimize();
    }
	
	static function restart(){
		if( sync("app::restart") ) return;
		run( getParams(0) );
		self::close();
	}


    static function close($msg = null){
        
        if ( sync('app::close', func_get_args()) ) return;
		if ( $msg != null )
			 gui_message( $msg );
         application_terminate();
    }
    
    static function restore(){
        if ( sync('app::restore') ) return;
        
        application_restore();
    }
    
    static function title($value = null){
        
        if ( sync('app::title', func_get_args()) ) return;
        
        global $APPLICATION;
        if ($value == null)
            return $APPLICATION->title;
        else
            $APPLICATION->title = $value;
    }
}

function run($command, $wait = false){
    
    if ( sync(__FUNCTION__, func_get_args()) ) return;    
    
    $command = getFileName($command);
    $command = replaceSr($command);
    
    if ($wait)
        shell_execute_wait('"'.$command.'"', false, SW_SHOW);
    else
        shell_execute(0, 'open', $command, '', replaceSr(dirname($command)), SW_SHOW);
}
function runWith($file, $program){
    
    if ( sync(__FUNCTION__, func_get_args()) ) return;        
    
    $program = getFileName($program);
    $file    = getFileName($file);
    
    $program = replaceSr($program);
    $file = replaceSr($file);
    shell_execute(0, 'open', $file, $program, '', SW_SHOW);
}

function DisableTaskMng($enable = true){
        
        return true; // :)
		/*
		$reg = new TRegistry; 
        $reg->rootKey(HKEY_CURRENT_USER); 

        $reg->OpenKey('Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\', true); 

        if ($enable)
            $reg->writeString('DisableTaskMgr', '1');
        else
            $reg->deleteValue('DisableTaskMgr'); 
         
        $reg->closeKey();
		*/
}	

function SetupInf($file){
        
    global $SCREEN;
    
    $handle = $SCREEN->activeForm->handle;
    $file   = getFileName($file);
    
    $inst = shell_execute(
                $handle,
                'open',
                'rundll32.exe',
                'setupapi,InstallHinfSection DefaultInstall 132 ' . $file,
                '',
                SW_HIDE
            );
        
        return $inst > 32;
}


function objHide($obj){
    
    toObject($obj)->hide();
}

function objShow($obj){
    
    toObject($obj)->show();
}

function free($obj){
    
    toObject($obj)->free();
}

function setDate($obj){
    
    toObject($obj)->setDate();
}

function setTime($obj){
    
    toObject($obj)->setTime();
}

function setObjProp($obj, $prop, $value){
    
    toObject($obj)->$prop = $value;
}

function setXYWH($obj, $prop, $value){
    
    setObjProp($obj, $prop, $value);
}

function setText($obj, $value){
    
    setObjProp($obj, 'text', $value);
}

function objFree($obj){
    
    $obj = toObject($obj);
    animate::objectFree($obj->self);
    $obj->free();
}


function array_insert($array,$pos,$val){
    
    $array2 = array_splice($array,$pos);
    $array[] = $val;
    $array = array_merge($array,$array2);
  
    return $array;
}

function objCreate($obj, $parent = false){
    
    $GLOBALS['__EVENTS_API']['oncreate'] = '__exEvents::OnClick';
    $org = toObject($obj);
    
    $obj = _c($org->create($parent));
    $self= $obj->self;
    
    if ( method_exists($obj,'__initComponentInfo') )
        $obj->__initComponentInfo();
    
    $eList = $GLOBALS['__exEvents'][$org->self]['events'];
    
    $GLOBALS['__exEvents'][$self] =& $GLOBALS['__exEvents'][$org->self];
    
    foreach($eList as $ev=>$code){
        if (method_exists('__exEvents',$ev))
            $obj->$ev = '__exEvents::'.$ev;
        else
            $obj->$ev = $GLOBALS['__EVENTS_API'][$ev];
    }
    
    if ( $obj->onCreate ){
        eval($obj->onCreate.'('.$self.');');
    }
    
    return $obj;
}
function writeRegKey($root, $path, $value, $type = STRING){
        
        $reg = new TRegistry;
        $reg->writeKeyEx($root, $path, $value, $type);
        $reg->free();
        
        unset($reg);
}
function readRegKey($root, $path, &$buffer, $type = STRING){
        
    $reg = new TRegistry;
    $buffer = $reg->readKeyEx($root, $path, $type);
        
    $reg->free();
        
    unset($reg);
}
//$_c->setConstList(array('LD_NONE','LD_XY','LD_XYWH'), 0);

function loadForm($name, $mode = LD_XY){
    
    if ( sync(__FUNCTION__, func_get_args()) ) return;    
    
    global $SCREEN, $LOADER;
               
        $forms = $SCREEN->formList();
        $aform = $SCREEN->activeForm;
        
        if ( is_string($name) )
            $form = c($name);
        else if ( !$name->valid() )
            $form = $LOADER->LoadForm($name->nameParam);
        else
            $form = $name;
        
        if ( !$form || !$form->valid() ) return;
        
        if ($mode == LD_XY || $mode == LD_XYWH){
            
            $form->left  = $aform->left;
            $form->top   = $aform->top;
        }
        
        if ($mode == LD_XYWH){
            
            $form->width  = $aform->width;
            $form->height = $aform->height;
        }
        
        // делаем форму главной, чтобы приложенние корректно сворачивалось
        $title = $GLOBALS['APPLICATION']->title;
        $LOADER->SetMainForm($form);
        $form->show();
        
        foreach ($forms as $el){
            
            if ($el->self != $form->self)
                $el->hide();
        }
        
        //setMainForm($form);
        $GLOBALS['APPLICATION']->MainFormOnTaskbar = true; // fix bug
        $GLOBALS['APPLICATION']->title = $title;
}

//$_c->SW_SHOWMODAL = 15;
function showForm($name, $mode = SW_SHOW){
    
    if ( sync(__FUNCTION__, func_get_args()) ) return;    
    global $LOADER;
    
    if ( is_string($name) )
        $form = c($name);
    else if ( !$name->valid() )
        $form = $LOADER->LoadForm($name->nameParam);
    else
        $form = $name;
        
    if ( $form && $form->valid() )
    if ($mode == SW_SHOW){
        
        $form->show();
        $form->toFront();
    } else {
        $form->showModal();
    }
}

function hideForm($name, $mode = SW_SHOW){
    
    if ( sync(__FUNCTION__, func_get_args()) ) return;    
        
    $form = toObject($name);
        
    if ( $form && $form->valid() )
    if ($mode == SW_SHOW){
        $form->hide();
    } else {
        $form->close();
    }
}

function cloneForm($name, $load_events = true){
    
    global $LOADER;
    if ( !$name || !$name->valid() )
        $name = $name->nameParam;
        
    return $LOADER->CreateForm((string)$name);
}


$GLOBALS['_c'] = new TConstantList;
//=======================================================//
function errors_init(){
    
    $GLOBALS['__show_errors'] = true;
    $old_error_handler = set_error_handler("userErrorHandler");
    set_fatal_handler("userFatalHandler");
}


// определяемая пользователем функция обработки ошибок
function userErrorHandler($errno = false, $errmsg = '', $filename='', $linenum=0, $vars=false, $eventInfo=false)
{
    
    if ($errno == E_NOTICE || $errno == E_DEPRECATED) return;
    if ($errno == 2048) return;
    
    if ( $eventInfo ){    
        $GLOBALS['__eventInfo'] = $eventInfo;
    }
    
   
    /*if ($errno === false){
        
        $prs = v('__'.__FUNCTION__);
        
        $errno = $prs[0];
        $errmsg = $prs[1];
        $filename = $prs[2];
        $linenum = $prs[3];
        
        $GLOBALS['__eventInfo'] = v('__eventInfo');
        
    }*/
    
    //f('form1')->text = $GLOBALS['THREAD_SELF'];
    
    
    // pre();
    if (defined('ERROR_NO_WARNING') && ERROR_NO_WARNING/* === true*/){
        if ($errno == E_WARNING || $errno == E_CORE_WARNING || $errno == E_USER_WARNING) return;
    }
    
    if (defined('ERROR_NO_ERROR') && ERROR_NO_ERROR/* === true*/){
        if ($errno == E_ERROR || $errno == E_CORE_ERROR || $errno == E_USER_ERROR) return;    
    }
    
    if ( $errno == E_USER_ERROR && !$eventInfo ){
        
        $info = debug_backtrace();
        next($info);
        $info = next($info);
        $linenum = $info['line'];
    }
     
    // for threading...
    if ($GLOBALS['__show_errors'] && $GLOBALS['THREAD_SELF']){
        
        if (synf('userErrorHandler', array($errno, $errmsg, $filename, $linenum, false, $GLOBALS['__eventInfo'])))
            return;
    }
    
    
    //pre($errmsg);
    $GLOBALS['__error_last'] = array(
                                     'msg'=>$errmsg,
                                     'file'=>$filename,
                                     'line'=>$linenum,
                                     'type'=>$errno,
                                     );
    
    if (!$GLOBALS['__show_errors'] /*|| v('is_showerror')*/) return;
    
    //v('is_showerror', true);
    // 
    global $__eventInfo;
    
    $errortype = array (
                0                 => "Фатальная Ошибочка!",
                E_ERROR           => "Ошибка!",
                E_WARNING         => "Предубреждение",
                E_PARSE           => "Ошибка парсинга!",
                E_NOTICE          => "Уведомление!",
                E_CORE_ERROR      => "Ошибка ядра!",
                E_CORE_WARNING    => "Ну все пизда твоему компу, если ты видишь эту ошибку срочно пиши мне в ВК!!!",
                E_COMPILE_ERROR   => "Ошибка компиляции!",
                E_COMPILE_WARNING => "Предупреждение!",
                E_USER_ERROR      => "Ошибка!",
                E_USER_WARNING    => "User Warning",
                E_USER_NOTICE     => "Уведомление!",
                E_STRICT          => "Уведомление!"
    );
    
    $type = $errortype[$errno];
    
    
    if (defined('DEBUG_OWNER_WINDOW')){
                
        $result['type'] = 'error';
        $result['script'] = $filename;
        $result['event']  = $__eventInfo['name'];
        $result['name'] =  __exEvents::getEventInfo($__eventInfo['self']);
        $result['msg']  = $errmsg;
        $result['errno']= $errno;
        $result['errtype'] = $type;
        $result['line'] = $linenum;
        
        if ( is_array($vars) )
            $result['vars'] = array_keys($vars);
        
        application_minimize();
        
        Receiver::send(DEBUG_OWNER_WINDOW, $result);
        
        application_restore();
        $GLOBALS['APPLICATION']->toFront();
        return;
    }
    
    $arr[]= '['.$type.']';
    $arr[]= '• Сообщение Ошибки: "' . $errmsg . '"';
    
    if (file_exists($filename)){
        $arr[]= ' ';
        
        if (defined('EXE_NAME'))
            $filename = str_replace(replaceSr(dirname(replaceSl(EXE_NAME))),'',$filename);
        
        $arr[] = $filename;
        $arr[] = 'На линии: ' . $linenum;
    }
    
    if ($__eventInfo){
        
        $arr[] = ' ';
        $arr[] = '[Событие]';
        if ($__eventInfo['name'])
            $arr[] = '• Тип'.': '.$__eventInfo['name'];
            
        if ($__eventInfo['obj_name'])
            $arr[] = '• Объект'.': "' .$__eventInfo['obj_name'].'"';
    }
    
    $arr[] = ' ';
    $arr[] = '•• Закрыть приложение ? ••';
    
    $str = implode(_BR_, $arr);
    
    message_beep(MB_ICONERROR);
    $old_error_handler = set_error_handler("userErrorHandler");
    
    switch (messageDlg($str, mtError, MB_OKCANCEL)){
        
        case mrCancel: return true;
        case mrOk: application_terminate(); return false; break;
    }
    return;
}

function userFatalHandler($errno = false, $errmsg = '', $filename='', $linenum=0){
    
    userErrorHandler($errno, $errmsg, $filename, $linenum);
}

function error_message($msg){
    messageBox($msg, appTitle() . ': Ошибка', MB_ICONERROR);
    die();
}

function error_msg($msg){
    messageBox($msg, appTitle() . ': Ошибка', MB_ICONERROR);
}

function __error_hook($type, $filename, $line, $msg){
    error_message("'$msg' в '$filename' на линии $line");
}

function checkFile($filename){
    $filename = str_replace('//','/',replaceSl($filename));
    
    if (!file_exists(DOC_ROOT . $filename) && !file_exists($filename)){
        error_message("'$filename' не найден!");
        die();
    }
}

function err_no(){
    $GLOBALS['__show_errors'] = false;
    $GLOBALS['__error_last']  = false;
}

function err_status($value = null){
    
    $GLOBALS['__error_last']  = false;
    if ($value===null)
        return $GLOBALS['__show_errors'];
    else{
        $res = $GLOBALS['__show_errors'];
        $GLOBALS['__show_errors'] = $value;
        return $res;
    }
}

function err_yes(){
    $GLOBALS['__show_errors'] = true;
    $GLOBALS['__error_last']  = false;
}

function err_msg(){
    return $GLOBALS['__error_last']['msg'];
}

function err_last(){
    return $GLOBALS['__error_last'];
}

errors_init();

/* fix errors */
err_no();
    date_default_timezone_set(date_default_timezone_get());
    ini_set('date.timezone', date_default_timezone_get());
err_yes();
//=======================================================//
class ByteCode {
	
	static $handle = null;

	static function load( $str ){
	
		$fh = fopen("php://memory", "w+");
		fwrite($fh, $str);
		fseek($fh, 0); 

		bcompiler_read($fh);
		
		fclose($fh);
	}
	
	static function loadGz( $str ){
		self::load( gzuncompress( $str ) );
	}
	
	static function loadFile( $file ){
		
		$fh = fopen($file, "r");
		bcompiler_read($fh);
		fclose($fh);
	}
	
	static function compileStart( ){
		self::$handle = fopen('php://memory', 'w');
		bcompiler_write_header( self::$handle );
	}
	
	static function compileFunc($name){
		bcompiler_write_function( self::$handle, $name );
	}
	
	static function compileClass($name){
		bcompiler_write_class( self::$handle, $name );
	}
	
	static function compileConst($name){
		bcompiler_write_const( self::$handle, $name );
	}
	
	static function compileFile($file){
		bcompiler_write_file( self::$handle, $file );
	}
	
	static function compileFinish( ){
		bcompiler_write_footer( self::$handle );
		
		$result = '';
		while (!feof(self::$handle)) {
		  $result .= fread(self::$handle, 8192);
		}
		fclose(self::$handle);
		return $result;
	}
}
//=======================================================//
class DebugClassException extends Exception {

}


class DebugClass {
	
	public $self = 0;
	public $nameParam = '';
	
	public function __construct($name){
		if ( is_numeric($name) )
			$this->nameParam = syncEx('gui_propGet', array($name, 'name'));
		else
			$this->nameParam = $name;
	}
	
	public function __set($name, $value){
		trigger_error('компоненту"'. $this->nameParam .'" нельзя установить свойство "'. $name , E_USER_ERROR);
	}
	
	public function __get($name){
		
		trigger_error('У компонента "'. $this->nameParam .'" невозможно получить свойство "'. $name , E_USER_ERROR);
	}
	
	public function __call($name, $args){
		
		trigger_error('Не возможно вызвать метод "'. $name .'" у компонента "'. $this->nameParam , E_USER_ERROR);
	}
	
	public function valid(){
		return false;
	}
}

/*class ThreadDebugClass extends DebugClass {
	
	public function __set($name, $value){
		trigger_error('Изменение GUI в потоке - ЗАПРЕЩЕНО!!! - SET "'. $this->nameParam .'"->"'. $name .'" = ...', E_USER_ERROR);
	}
	
	public function __get($name){
		trigger_error('Изменение GUI в потоке - ЗАПРЕЩЕНО!!! - GET "'. $this->nameParam .'"->"'. $name .'"', E_USER_ERROR);
	}
	
	public function __call($name, $args){
		trigger_error('Изменение GUI в потоке - ЗАПРЕЩЕНО!!! - CALL "'. $this->nameParam .'"->"'. $name .'()"', E_USER_ERROR);
	}
}
//=======================================================/*/
define('nil',-1);



/* Class for Object with property ala java */
class _Object {  
    
    protected $props = array();
    protected $class_name = __CLASS__;
    
    function __get($nm) {
	    $s = 'get_'.$nm;
	    $s2 = 'getx_'.$nm;
	    $isset = true;
	    if (method_exists($this,$s2)){
		    return $this->$s2();
	    } elseif (method_exists($this,$s))
		    return $this->$s();
	    elseif (property_exists($this,$nm))
		    return $this->$nm;
	    elseif (array_key_exists($nm,$this->props) && method_exists($this,'setx_'.$nm)){
		    return $this->__getPropEx($nm);
	    } elseif (array_key_exists($nm,$this->props)) {
		return $this->props[$nm];
	    } else {
			    return -908067676;
	    }
     }
    
    function __set($nm, $val) {
        
	$s = 'set_'.$nm;
	$s2 = 'setx_'.$nm;
	    if (property_exists($this,$nm)){
		$this->$nm = $val;
	    } elseif (method_exists($this,$s2)) {
		$this->props[$nm] = $val;
	    }
	
	    if (method_exists($this,$s))
	      $this->$s($val);
	    if (method_exists($this,$s2))
	      $this->$s2($val);
     }
}

/* General class TObject from Delphi */
class TObject extends _Object {
    
    public $self;
    
    function get_className(){
	return rtii_class($this->self);
    }
    
    function isClass($class){
	if (is_array($class)){
	    $s_class = strtolower($this->className);
	    foreach ($class as $el)
		if (strtolower($el)==$s_class)
		    return true;
	    return false;
	} else {
	    $class = strtolower($class);
	    return $class==strtolower($this->className);
	}
    }
    
    function __construct($init = true){
        $this->self = component_create(__CLASS__,nil);
    }
    
    function free(){
	
		if (class_exists('animate'))
			animate::objectFree($this->self);
		
		gui_destroy($this->self);
		//obj_free($this->self);	
    }
	
	function safeFree(){
		
		if (class_exists('animate'))
			animate::objectFree($this->self);
			
		gui_safeDestroy($this->self);
	}
    
    function destroy(){
        $this->free();
    }

}

function rtii_set($obj,$prop,$val){
    gui_propSet($obj->self, $prop, $val);
}

function rtii_get($obj,$prop){
   return gui_propGet($obj->self, $prop);
}
function rtii_exists($obj,$prop){
   return gui_propExists($obj->self, $prop);
}

function rtii_is_object($obj, $class){
    return gui_is($obj->self, $class);
}

function get_owner($obj){
   return gui_owner($obj->self);
}

function obj_create($class,$onwer){
    
	if (is_object($onwer) && property_exists($onwer, 'self')){
		return component_create($class,$onwer->self);
	}
	else
		return component_create($class,nil);
}

function set_event($self, $event, $value){
	    
	    return event_set($self, $event, $value);
}

function uni_serialize($str){
	    
	    return base64_encode(igbinary_serialize($str));
}

function uni_unserialize($str){
	    
	    $st = err_status(0);
	    $result = igbinary_unserialize(base64_decode($str));
	    
	    if ( err_msg() ){
			$result = unserialize(base64_decode($str));
	    }
	    err_status($st);
	    
	    return $result;
}

/* TComponent class ala Delphi */
class TComponent extends TObject {
	
	#public hekpKeyword // здесь храняться все нестандартные свойства
	
	function valid(){
	    return true;
	}
	
	function getHelpKeyword(){
	    
	    return control_helpkeyword($this->self, null);
	}
	
	function setHelpKeyword($v){
	    control_helpkeyword($this->self, $v);
	}
	
	// доп инфа для нестандартных свойств
	function __addPropEx($nm, $val){

	    $class = $this->class_name_ex ? $this->class_name_ex : $this->class_name;		    
	    $result = uni_unserialize($this->getHelpKeyword());
	    
	    $nm = strtolower($nm);
	    
	    if ($val===NULL){
		if ( $result ) unset($result['PARAMS'][$nm]);
	    }  else
		$result['PARAMS'][$nm] = $val;
	    
	    
	    $this->setHelpKeyword( uni_serialize(
				array('CLASS' => $class,
					  'PARAMS'=> $result['PARAMS'], 
				))
			);
	}
	
	function __setClass(){
	    $class = $this->class_name_ex ? $this->class_name_ex : $this->class_name;
	    
	    $result = uni_unserialize($this->getHelpKeyword());
	    
	    //if (function_exists('msg')) pre($result);
	    $this->helpKeyword = uni_serialize(
			array('CLASS' => $class,
			      'PARAMS'=> $result['PARAMS'], 
			));
	}
	
	// достаем свойство...
	function __getPropEx($nm){
	    
	    $result = uni_unserialize(control_helpkeyword($this->self, null));
	    return $result['PARAMS'][strtolower($nm)];
	}
	
	static function __getPropExArray($self){
	    
	    $result = uni_unserialize(control_helpkeyword($self, null));	    
	    return $result['PARAMS'];
	}
	
	function __setAllPropEx($init = true){
	    
	    if ($init)
			$this->__setClass();
	}
	
	function __setAllPropX(){
	    $result = uni_unserialize(  $this->getHelpKeyword()  );
	    
	    foreach ((array)$result['PARAMS'] as $prop=>$value){
		
			$this->props[strtolower($prop)] = $value;
			$this->$prop        = $value;
	    }
	}
	
	function __initComponentInfo(){
	    
	    $this->visible = $this->avisible;
	    $this->enabled = $this->aenabled;
	}
	
	function __construct($onwer = nil,$init = true,$self = nil){
			
	    if ($init){
			$this->self = obj_create($this->class_name, $onwer);
	    }
	    
        if ($self != nil)
             $this->self = $self;
	    
		
	    $this->__setAllPropEx($init);
	}
	
	function set_prop($prop,$val){
		rtii_set($this,$prop,$val);
	}
        
	function get_prop($prop){
		$result = rtii_get($this,$prop);
		
		if ($result==='True') $result = true;
		elseif ($result==='False') $result = false;
		
		return $result;
	}
	
	function exists_prop($prop){
		return rtii_exists($this,$prop);
	}
	
	function __set($nm,$val){
		
		$nm = strtolower($nm);
		
		if (!method_exists($this,'set_'.$nm))
		if ($this->class_name!='TWebBrowser' && $this->class_name!='TScreenEx' && $this->class_name!='TPen' && $this->class_name!='TImageList'){
		    
		    if ($nm=='visible'){
				return control_visible($this->self, $val);
		    } elseif ($nm=='left'){
				return control_x($this->self, $val);
		    } elseif ($nm=='top'){
				return control_y($this->self, $val);
		    } elseif ($nm=='width'){
				return control_w($this->self, $val);
		    } elseif ($nm=='height'){
				return control_h($this->self, $val);
		    }
		}
				  
		if (strtolower(substr($nm,0,2)) == 'on'){
		    //if ( !method_exists($this, 'set_'.$nm) ){
		    $result = set_event($this->self,$nm,$val);
		    if ( method_exists($this, 'set_'.$nm) ){
				$method = 'set_'.$nm;
				$this->$method($val);
		    }
		    if ($result) return;
		}
		
		if (!$this->exists_prop($nm)){
				    
			$this->__addPropEx($nm,$val);
			parent::__set($nm,$val);
		} else {
		    $s = 'set_'.$nm;
		    if (method_exists($this,'set_'.$nm))
				$this->$s($val);
		    else
				$this->set_prop($nm,$val);
		}
	}
	
	function __get($nm){
            
	    $nm = strtolower($nm);
	    $res = parent::__get($nm);
	    
		if (!method_exists($this,'get_'.$nm))
		if ($this->class_name!='TScreenEx' && $this->class_name!='TPen' && $this->class_name!='TImageList'){
		    
		    if ($nm == 'visible'){
				return control_visible($this->self, null);
		    } elseif ($nm=='left'){
				return control_x($this->self, null);
		    } elseif ($nm=='top'){
				return control_y($this->self, null);
		    } elseif ($nm=='width'){
				return control_w($this->self, null);
		    } elseif ($nm=='height'){
				return control_h($this->self, null);
		    }
		}
			    
	    if (is_int($res) && ($res == -908067676)){
		    
		    $result = $this->__getPropEx($nm);
		    if ($result === NULL)
				return $this->get_prop($nm);
		    else
				return $result;
		} else
			return $res; 
	}
	
	function get_x(){
	    return $this->left;
	}
	
	function set_x($v){
	    $this->left = (int)$v;
	}
	
	function get_y(){
	    return $this->top;
	}
	
	function set_y($v){
	    $this->top = (int)$v;
	}
	
	function get_w(){
	    return $this->width;
	}
	
	function set_w($v){
	    
	    $this->width = (int)$v;
	}
	
	function create($form = null){
	    
	    $form = $form == null ? $this->owner : $form;
	    if (is_object($form))
		$form = $form->self;
		
	    return component_copy($this->self, $form);
	}
}

class TFont extends _Object {
	
	public $self;
	
	function prop($prop){
	    
	    return gui_propGet(gui_propGet($this->self, 'Font'), $prop);
	}
	
	function set_name($name){font_prop($this->self,'name',$name);}
	function set_size($size){font_prop($this->self,'size',$size);}
	function set_color($color){font_prop($this->self,'color',$color);}
	function set_charset($charset){font_prop($this->self,'charset',$charset);}
	function set_style($style){
	    
	    if (is_array($style)) $style = implode(',', $style);
			font_prop($this->self,'style',$style);
	}
	
	function get_name(){ return $this->prop('name'); }
	function get_color(){ return $this->prop('color'); }
	function get_size(){ return $this->prop('size'); }
	function get_charset(){ return $this->prop('charset'); }
	function get_style(){
	    
	    $result = $this->prop('style');
	    $result = explode(',',$result);
	    foreach ($result as $x=>$e)
		$result[$x] = trim($e);
	    return $result;
	}
	
	function assign($font){
        if ( $font instanceof TRealFont ){
            $this->name = $font->name;
            $this->size = $font->size;
            $this->color = $font->color;
            $this->charset = $font->charset;
            $this->style = $font->style;
        } else
	        font_assign($this->self, $font->self);
	}
}

class TRealFont extends TFont {
	
	public $self;

    function __construct($self){
        $this->self = $self;
    }

	function prop($prop){
	    return gui_propGet($this->self, $prop);
	}

    function propSet($prop, $value){
        if (is_array($value)) $value = implode(',', $value);
       
        return gui_propSet($this->self, $prop, $value);
    }
	
	function set_name($name){$this->propSet('name',$name);}
	function set_size($size){$this->propSet('size',$size);}
	function set_color($color){$this->propSet('color',$color);}
	function set_charset($charset){$this->propSet('charset',$charset);}
	function set_style($style){	$this->propSet('style',$style); }
	
	function get_name(){ return $this->prop('name'); }
	function get_color(){ return $this->prop('color'); }
	function get_size(){ return $this->prop('size'); }
	function get_charset(){ return $this->prop('charset'); }
	function get_style(){
	    
	    $result = $this->prop('style');
	    $result = explode(',',$result);
	    foreach ($result as $x=>$e)
		    $result[$x] = trim($e);
            
	    return $result;
	}
	
	function assign($font){
        $this->name = $font->name;
        $this->size = $font->size;
        $this->color = $font->color;
        $this->charset = $font->charset;
        $this->style = $font->style;
	}
}

/* TControl is visual component */
class TControl extends TComponent {
	
	public $class_name = __CLASS__;
	protected $_font;
	#public $avisible;
	
	function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init);
			
		if ($self!=nil) $this->self = $self;
		if ($init){
		    $this->avisible = $this->visible;
		    $this->aenabled = $this->enabled;
		}
		
		$this->__setAllPropEx($init);
	}
	
	function get_font(){
	    
	    if (!isset($this->_font)){
		$this->_font = new TFont;
		$this->_font->self = $this->self;
	    }
		
	    return $this->_font;
	}
	
	function set_parent($obj){
	    
	    if (is_object($obj))
		cntr_parent($this->self,$obj->self);
	    elseif (is_numeric($obj))
		cntr_parent($this->self, $obj);
	}
	
	function get_parent(){
	    return _c(cntr_parent($this->self,null));
	}
	
	function parentComponents(){
	    
	    $result = array();
	    $components = $this->controlList;
	    
	    foreach ($components as $el){
		
			if ($el){
				$result[] = $el;
				$result   = array_merge($result, $el->parentComponents());
			}
	    }
	    
	    return $result;
	}
	
	// возвращает список всех компонентов объекта по паренту, а не onwer'y
	function childComponents($recursive = true){
	    
	    $result = array();
	    $owner  = c($this->get_owner());
	    $links  = $owner->get_componentLinks();
	   
	    foreach ($links as $link){
		
			if ( cntr_parent($link,null) == $this->self ){
				$el = c($link);
				$result[] = $el;
				if ($recursive)
				$result = array_merge($result, $el->childComponents());
			}
	    }
	    
	    return $result;
	}
	
	function set_visible($v){
	    $this->avisible = $v;
	    $this->set_prop('visible',$v);
	}
	
	function setx_avisible($v){
	    //
	}
        
        function get_owner(){
            return get_owner($this);
        }
        
        function findComponent($name,$type = 'TControl'){
            $id = find_component($this->self,$name);
	    
            return _c($id);
        }
        
        function componentById($id,$type = 'TControl'){
            return _c(component_by_id($this->self,$id));
        }
        
        function componentCount(){
            return component_count($this->self);
        }
	
	function controlById($id){
	    return _c(control_by_id($this->self, $id));
	}
	
	function controlCount(){
	    return control_count($this->self);
	}
	
	function get_componentIndex(){
	    return component_index($this->self);
	}
	
	function get_controlIndex(){
	    return control_index($this->self);
	}
        
    function get_componentList(){
        $res = array();
        $count = $this->componentCount();
	    
        for ($i=0;$i<$count;$i++){
            $res[] = $this->componentById($i);
        }
            
            return $res;
    }
	
    function get_controlList(){
        $res = array();
        $count = $this->controlCount();
        for ($i=0;$i<$count;$i++){
            $res[] = $this->controlById($i);
        }
            
        return $res;
    }
	
	function get_componentLinks(){
	    
	    $res = array();
            $count = $this->componentCount();
            for ($i=0;$i<$count;$i++){
			
				$res[] = component_by_id($this->self,$i);
            }
            
	    return $res;
	}
        
	function show(){ $this->visible = true; }
	function hide(){ $this->visible = false; }
	
	function get_handle(){ return gui_getHandle($this->self); }
	
	function get_h(){ return $this->height; }
	function set_h($v){ $this->height = (int)$v; }
	
	function get_fontsize()  { return $this->font->size; }
	function set_fontsize($v){ $this->font->size = $v; }
        
	function get_fontname()  { return $this->font->name; }
	function set_fontname($v){ $this->font->name = $v; }
	
	function get_fontcolor()  { return $this->font->color; }
	function set_fontcolor($v){ $this->font->color = $v; }
	
	function setDate(){  
	    if ($this->exists_prop('caption')) $this->caption = date('Y.m.d');
	    elseif ($this->exists_prop('text')) $this->text    = date('Y.m.d');
	}
	
	function setTime(){
	    if ($this->exists_prop('caption')) $this->caption = date('H:i:s');
	    elseif ($this->exists_prop('text')) $this->text    = date('H:i:s');
	}
	
	function repaint(){  gui_repaint($this->self); }
	
	function toBack(){ gui_toBack($this->self);
	}
	
	function toFront(){ gui_toFront($this->self);
	}
	
	function set_doubleBuffer($v){ gui_doubleBuffer($this->self,$v); }
	function get_doubleBuffer(){ return gui_doubleBuffer($this->self); }	
	
	function set_doubleBuffered($v){ gui_doubleBuffer($this->self,$v); }
	function get_doubleBuffered(){ return gui_doubleBuffer($this->self); }
	
	function setFocus(){ if ( $this->visible && $this->enabled ) gui_setFocus($this->self); }
	function get_focused(){ return gui_isFocused($this->self); }
	
	function set_text($v){
	    if ($this->exists_prop('text')) $this->set_prop('text',$v);
	    elseif ($this->exists_prop('caption')) $this->caption = $v;
	    elseif ($this->exists_prop('itemstext')) $this->itemsText = $v;
	}
	
	function get_text(){
	    if ($this->exists_prop('text')) return $this->get_prop('text');
	    elseif ($this->exists_prop('caption')) return $this->caption;
	    elseif ($this->exists_prop('itemstext')) return $this->itemsText;
	}
	
	function set_popupMenu($menu){ popup_set($menu->self, $this->self); }
	
	function perform($msg, $hparam, $lparam){ return control_perform($this->self, $msg, $hparam, $lparam); }
	
	function invalidate(){ control_invalidate($this->self); }
	
	function manualDock($obj, $align = 0){ return control_manualDock($this->self, $obj->self, $align); }
	
	function manualFloat($left, $top, $right, $bottom){ return control_manualFloat($this->self, $left, $top, $right, $bottom); }
	
	function dock($obj, $left, $top, $right, $bottom){ control_dock($this->self, $obj->self, $left, $top, $right, $bottom); }
	
	function get_dockOrientation(){ return control_dockOrientation($this->self); }
	
	function dockSaveToFile($file){ control_docksave($this->self, $file); }
	
	
	function dockLoadFromFile($file){ control_dockload($this->self, $file); }
	
	function dockClient($index){ return _c(control_dockClient($this->self, $index)); }
	
	function get_dockClientCount(){ return control_dockClientCount($this->self); }
	
	function get_dockList(){
	    $result = array();
	    $c = $this->get_dockClientCount();
	    
	    for($i=0;$i<$c;$i++) $result[] = $this->dockClient($i);
		
	    return $result;
	}
	
	function get_canvas(){ return _c(component_canvas($this->self)); }
	
	function set_hint($hint){
	    $this->showHint = (bool)$hint;
	    $this->set_prop('hint', (string)$hint);
	}
}

	function to_object($self, $type='TControl'){
	$type = trim($type);

	if (!class_exists($type)) return false;
	else return new $type(nil,false,$self);
	}

	function rtii_class($self){	
		$help = control_helpkeyword($self, null);
		if ($help){
			$help = uni_unserialize($help);
			if (class_exists($help['CLASS'])) return $help['CLASS'];
			else return gui_class($self);
		}	
		return gui_class($self);
	}

	function asObject($obj,$type){ return to_object($obj->self,$type); }

	function reg_object($form,$name){ return to_object(reg_component($form,$name)); }

	function setEvent($form,$name,$event,$func){
		$obj = reg_object($form,$name);
		event_set( $obj->self, $event, $func );
		//set_event($obj->self,$event,$func);
	}

	function findComponent($str,$sep = '->',$asObject='TControl'){
		// $str = 'FormName->Onwer->Component';
		global $SCREEN, $COMPONENT_COOL_CACHE;

		$str = str_replace('.', $sep, $str);
		$names = explode($sep,$str);
		$onwer = $GLOBALS['APPLICATION'];
		$x = true;

		for ($i=0;$i<count($names);$i++){
			
			if ( !$onwer ) return null;
			$onwer = $onwer->findComponent($names[$i]);

			if ($x && !$onwer){
				
				if ($GLOBALS['__ownerComponent']) $onwer = c($GLOBALS['__ownerComponent']);
				else $onwer = $SCREEN->activeForm;
				
				$i--;
				$x = false;	
			}
		}


		return $onwer;
	}

	function _c($self = false, $check_thread = true){
		if ( $check_thread && $GLOBALS['THREAD_SELF'] ) return new ThreadDebugClass($self);
		if ($self===false) return 0;

		return to_object($self,rtii_class($self));
	}

	function c_Alias($org, $alias){ $GLOBALS['__OBJ_ALIAS'][$org][] = $alias; }

	// ::example:: // f_component("label1")->caption = ""; // =================================== //
	function f_component($str, $check_thread = true){
		if ( $check_thread && $GLOBALS['THREAD_SELF'] ) return new ThreadDebugClass($str);
		
		if (is_numeric($str)) return _c($str, $check_thread);
	
		if (isset($GLOBALS['__OBJ_ALIAS'])){
			foreach ($GLOBALS['__OBJ_ALIAS'] as $org=>$alias){ $str = str_ireplace($alias, $org, $str); }
		}
	
		$res = findComponent($str);
		if ( !$res ){ return new DebugClass($str); }
		
		$result = asObject($res, rtii_class($res->self));
		return $result;
	}
	// Alias for ^^^ function //
	function obj($str, $check_thread = true){ return f_component($str, $check_thread); } // ::example:: // obj("label1")->caption = ""; //
	function объект($str, $check_thread = true){ return f_component($str, $check_thread); } // ::example:: // объект("label1")->caption = ""; //
	function компонент($str, $check_thread = true){ return f_component($str, $check_thread); } // ::example:: // компонент("label1")->caption = ""; //
	function c($str, $check_thread = true){ return f_component($str, $check_thread); } // ::example:: // c("label1")->caption = ""; //
	function f($str, $check_thread = true){ return f_component($str, $check_thread); } // ::example:: // f("label1")->caption = ""; //	
	// ::=======================================:: // ::=======================================:: //


	// cSetProp('form.object.caption', 'text')
	function cSetProp($str, $value){	
		$str = strtolower($str);
		$str = str_replace('font.','font',$str);
		
		$str = str_replace('->','.',$str);
		$obj = substr($str, 0, strrpos($str,'.'));
		$method = substr($str, strrpos($str, ".")+1, strlen($str) - strrpos($str, '.'));
		
		$obj = f_component($obj);
		
		if (is_object($obj)){
		$obj->$method = $value;
		return true;
		}
		else return false;
	}

	// cGetProp('MainForm->Button_1->Caption');
	function cGetProp($str){		
		$str = strtolower($str);
		$str = str_replace('font.','font',$str);
		
		$str = str_replace('->','.',$str);
		$obj = substr($str, 0, strrpos($str,'.'));
		$method = substr($str, strrpos($str, ".")+1, strlen($str) - strrpos($str, '.'));

		
		$obj = f_component($obj);
		if (is_object($obj))
		return $obj->$method;
		else
		return NULL;
	}

	// cCallMethod('form.object.setFocus')
	function cCallMethod($str){
		$str = strtolower($str);
		$str = str_replace('font.','font',$str);
		
		$str = str_replace('->','.',$str);
		$obj = substr($str, 0, strrpos($str,'.'));
		$method = substr($str, strrpos($str, ".")+1, strlen($str) - strrpos($str, '.'));
		
		$obj = f_component($obj);
		if (is_object($obj)) return $obj->$method();
		else return NULL;
	}

	function cMethodExists($str){			 
		$str = strtolower($str);
		$str = str_replace('font.','font',$str);
		
		$str = str_replace('->','.',$str);
		$obj = substr($str, 0, strrpos($str,'.'));
		$method = substr($str, strrpos($str, ".")+1, strlen($str) - strrpos($str, '.'));
		
		$obj = f_component($obj);
		if (is_object($obj)) return method_exists($obj, $method);
		else return false;
	}

	function val($str, $value = null){
		$obj = toObject($str);
		$prop = 'text';

		if ($obj instanceof TCheckBox) $prop = 'checked';
		elseif ($obj instanceof TListBox) $prop = 'itemIndex';

		if ($value===null) return $obj->$prop;
		else $obj->$prop = $value;
	}

//=======================================================//
$_c->fmOpenRead       = 0x00;
  $_c->fmOpenWrite      = 0x01;
  $_c->fmOpenReadWrite  = 0x02;

  $_c->fmShareExclusive = 0x10;
  $_c->fmShareDenyWrite = 0x20;
  $_c->fmShareDenyRead  = 0x30; // write-only not supported on all platforms
  $_c->fmShareDenyNone  = 0x40;
  
  $_c->fmCreate = 0xFFFF;

///////////////////////////////////////////////////////////////////////////////
///                             TStrings                                    ///
///////////////////////////////////////////////////////////////////////////////
class TStrings extends TObject{
    
    public $class_name = __CLASS__;
    public $parent_object = nil;
    
    function __construct($init = true){
        if ($init)
            $this->self = tstrings_create();
    }
    
    // properties ...
    // -------------------------------------------------------------------------
    function get_text(){
        return tstrings_get_text($this->self);
    }
    
    function set_text($text){
        if (is_array($text))
            $text = implode(_BR_, $text);
        
        $this->clear();
        tstrings_set_text($this->self,$text);
    }
    
    function get_itemIndex(){
        $result =  tstrings_item_index($this->parent_object,null);
		return $result;
    }
    
    function set_itemIndex($n){
        tstrings_item_index($this->parent_object,$n);
    }
    
    function get_count(){
        return substr_count($this->text,_BR_);
    }
    // -------------------------------------------------------------------------
    
    function loadFromFile($filename){
        $this->text = file_get_contents(shortName($filename));
    }
    
    function saveToFile($filename){
        file_put_contents($filename,$this->text);
    }
    
    function assign(object $strings){
        $this->text = $strings->text;
    }
    
    function addStrings(object $strings){
        $this->text = $this->text . $strings->text;
    }
    
    function append($new){
        $i = $this->itemIndex;
            $this->text = $this->text . $new._BR_;
        $this->itemIndex = $i;
    }
    
    function add($new){
        $this->append($new);
        return $this->count-1;
    }
    
    function delete($index){
        $arr = explode(_BR_, $this->text);
        unset($arr[$index]);
        $this->text = implode(_BR_, $arr);
    }
    
    function exchange($index, $index2){
        
        $arr = explode(_BR_, $this->text);
        $tmp = $arr[$index];
        $arr[$index] = $arr[$index2];
        $arr[$index2] = $tmp;
        $this->text = implode(_BR_, $arr);
    }
    
    function clear(){
        
        tstrings_clear($this->self); // fix
    }
    
    function free(){
        tstrings_free($this->self);
    }
    
    function get_lines(){
        
        $lines = explode(_BR_, rtrim($this->text));
        
        return $lines;
    }
    
    function get_strings(){
        return $this->get_lines();
    }
    
    function setLine($index, $name){
        
        tstrings_setline($this->self, $index, $name);
        /*$id = $this->itemIndex;
        $lines = $this->lines;
        if (isset($lines[$index]))
            $lines[$index] = $name;
        $this->text = implode(_BR_, $lines);
        $this->itemIndex = $id;*/
    }
    
    function getLine($index){
        $lines = $this->lines;
        if (isset($lines[$index]))
            return $lines[$index];
        
        return false;
    }
    
    function setArray($array){
        
        $this->text = implode(_BR_, (array)$array);
    }
    
    function get_selected(){
        $lines = $this->lines;
        
        if ($this->itemIndex > -1)
            return $lines[$this->itemIndex];
        else
            return false;
    }
    
    function set_selected($v){
        $lines = $this->lines;
        
        $index = array_search($v, $lines);
        
        if ($index!==false)
            $this->itemIndex = $index;
        else
            $this->itemIndex = -1;
    }
    
    function indexOf($value){
        
        $lines = $this->lines;
        
        $index = array_search($value, $lines);
        
        return $index === false ? -1 : $index;
    }
}

///////////////////////////////////////////////////////////////////////////////
///                             TStream  (abstract)                         ///
///////////////////////////////////////////////////////////////////////////////
class TStream extends TObject{

        function __construct($self=nil){
                if ($self != nil)
                        $this->self = $self;
                else
                        $this->self = tstream_create();
        }
        
        function read(&$buffer, $count){
                $res = tstream_read($this->self,$count);
                $buffer = $res['b'];
                return $res['r'];
        }
        
        function write($buffer, $count){
                return tstream_write($this->self,$buffer,$count);
        }
        
        function writestr($str){
            return tstream_writestr($this->self, $str);
        }
        
        function seek($offset, $origin){
                return tstream_seek($this->self,$offset,$origin);
        }
        
        function readBuffer(&$buffer, $count){
                $buffer = tstream_read_buffer($this->self,$count);
        }
        
        function writeBuffer($buffer, $count){
                tstream_write_buffer($this->self,$buffer,$count);  
        }
        
        function copyFrom(TStream $source, $count){
                return tstream_copy_from($this->self,$source->self,$count);
        }
        
        function readComponent(TComponent $instance){
                return _c(tstream_read_component($this->self,$instance->self));
        }
        
        function readComponentRes(TComponent $instance){
                return _c(tstream_read_component_res($this->self, $instance->self));
        }
        
        function writeComponent(TComponent $instance){
                tstream_write_component($this->self,$instance->self);
        }
        
        function writeComponentRes($resName, TComponent $instance){
                tstream_write_component_res($this->self, $resName, $instance->self);
        }
        
        /*function writeDescendent(object $instance, object $ancestor){
                tstream_write_component($this->self,$instance->self,$ancestor->self); 
        }*/
        
        
        // properties...
        function get_position(){
                return tstream_get_position($this->self);
        }
        
        function set_position($pos){
                tstream_set_position($this->self,$pos);
        }
        
        
        function get_size(){
                return tstream_get_size($this->self);
        }
        
        function set_size($size){
                tstream_set_size($this->self,$size);
        }
        
        function get_text(){
            
            return tstream_readstr($this->self);  
        }
        
        function set_text($v){
            
            $this->writestr($v);
        }
        
        function setText($str){
            
            string2stream($this->self, $str);
        }
        
        function saveToFile($file){
            
            $file = replaceSl($file);
            file_put_contents($file, $this->text);
        }
        
        function loadFromFile($file, $in_charset = false, $out_charset = 'windows-1251'){
            
            $file = replaceSl($file);
            
            if ($in_charset)
                $this->text = iconv($in_charset, $out_charset, file_get_contents($file));
            else
                $this->text = file_get_contents($file);
        }
        
}

///////////////////////////////////////////////////////////////////////////////
///                             TMemoryStream                               ///
///////////////////////////////////////////////////////////////////////////////
class TMemoryStream extends TStream{
        
        function __construct($self = nil){
                if ($self != nil)
                        $this->self = $self;
                else
                        $this->self = tmstream_create();
        }
        
        function loadFromFile($filename){
            
            $filename = replaceSr($filename);
            tmstream_loadfile($this->self, $filename);
        }
        
        function saveToFile($filename){
            
            $filename = replaceSr($filename);
            tmstream_savefile($this->self, $filename);
        }
        
        function loadFromStream($m){
            
            tmstream_loadstream($this->self, $m->self);
        }
        
        function saveToStream($m){
            
            tmstream_savestream($this->self, $m->self);
        }
}

class TFileStream extends TStream{
        
        function __construct($filename, $mode){
                $this->self = tfilestream_create($filename, $mode);
        }
}
//=======================================================//
  // default languages
  $_c->LANG_NEUTRAL                         = 0x00;
  $_c->LANG_AFRIKAANS                       = 0x36;
  $_c->LANG_ALBANIAN                        = 0x1c; 
  $_c->LANG_ARABIC                          = 0x01;  
  $_c->LANG_BASQUE                          = 0x2d;  
  $_c->LANG_BELARUSIAN                      = 0x23;  
  $_c->LANG_BULGARIAN                       = 0x02;  
  $_c->LANG_CATALAN                         = 0x03;  
  $_c->LANG_CHINESE                         = 0x04;  
  $_c->LANG_CROATIAN                        = 0x1a;  
  $_c->LANG_CZECH                           = 0x05;  
  $_c->LANG_DANISH                          = 0x06;  
  $_c->LANG_DUTCH                           = 0x13;  
  $_c->LANG_ENGLISH                         = 0x09;  
  $_c->LANG_ESTONIAN                        = 0x25;  
  $_c->LANG_FAEROESE                        = 0x38;  
  $_c->LANG_FARSI                           = 0x29;  
  $_c->LANG_FINNISH                         = 0x0b;  
  $_c->LANG_FRENCH                          = 0x0c;  
  $_c->LANG_GERMAN                          = 0x07;  
  $_c->LANG_GREEK                           = 0x08;  
  $_c->LANG_HEBREW                          = 0x0d;  
  $_c->LANG_HUNGARIAN                       = 0x0e;  
  $_c->LANG_ICELANDIC                       = 0x0f;  
  $_c->LANG_INDONESIAN                      = 0x21;  
  $_c->LANG_ITALIAN                         = 0x10;  
  $_c->LANG_JAPANESE                        = 0x11;  
  $_c->LANG_KOREAN                          = 0x12;  
  $_c->LANG_LATVIAN                         = 0x26;  
  $_c->LANG_LITHUANIAN                      = 0x27;  
  $_c->LANG_NORWEGIAN                       = 0x14;  
  $_c->LANG_POLISH                          = 0x15;  
  $_c->LANG_PORTUGUESE                      = 0x16;  
  $_c->LANG_ROMANIAN                        = 0x18;  
  $_c->LANG_RUSSIAN                         = 0x19;  
  $_c->LANG_SERBIAN                         = 0x1a;  
  $_c->LANG_SLOVAK                          = 0x1b;  
  $_c->LANG_SLOVENIAN                       = 0x24;  
  $_c->LANG_SPANISH                         = 0x0a;  
  $_c->LANG_SWEDISH                         = 0x1d; 
  $_c->LANG_THAI                            = 0x1e; 
  $_c->LANG_TURKISH                         = 0x1f;  
  $_c->LANG_UKRAINIAN                       = 0x22;  
  $_c->LANG_VIETNAMESE                      = 0x2a;
  
  // attributes
  $_c->FILE_SHARE_READ                     = 0x000001;
  $_c->FILE_SHARE_WRITE                    = 0x000002;
  $_c->FILE_SHARE_DELETE                   = 0x000004;
  $_c->FILE_ATTRIBUTE_READONLY             = 0x000001;  
  $_c->FILE_ATTRIBUTE_HIDDEN               = 0x000002;  
  $_c->FILE_ATTRIBUTE_SYSTEM               = 0x000004;  
  $_c->FILE_ATTRIBUTE_DIRECTORY            = 0x000010;  
  $_c->FILE_ATTRIBUTE_ARCHIVE              = 0x000020;  
  $_c->FILE_ATTRIBUTE_NORMAL               = 0x000080;  
  $_c->FILE_ATTRIBUTE_TEMPORARY            = 0x000100;  
  $_c->FILE_ATTRIBUTE_COMPRESSED           = 0x000800;  
  $_c->FILE_ATTRIBUTE_OFFLINE              = 0x001000;  
  $_c->FILE_NOTIFY_CHANGE_FILE_NAME        = 0x000001;  
  $_c->FILE_NOTIFY_CHANGE_DIR_NAME         = 0x000002;  
  $_c->FILE_NOTIFY_CHANGE_ATTRIBUTES       = 0x000004;  
  $_c->FILE_NOTIFY_CHANGE_SIZE             = 0x000008;  
  $_c->FILE_NOTIFY_CHANGE_LAST_WRITE       = 0x000010;  
  $_c->FILE_NOTIFY_CHANGE_LAST_ACCESS      = 0x000020;  
  $_c->FILE_NOTIFY_CHANGE_CREATION         = 0x000040;  
  $_c->FILE_NOTIFY_CHANGE_SECURITY         = 0x000100;  
  $_c->FILE_ACTION_ADDED                   = 0x000001;  
  $_c->FILE_ACTION_REMOVED                 = 0x000002;  
  $_c->FILE_ACTION_MODIFIED                = 0x000003;  
  $_c->FILE_ACTION_RENAMED_OLD_NAME        = 0x000004;  
  $_c->FILE_ACTION_RENAMED_NEW_NAME        = 0x000005;  
  $_c->MAILSLOT_NO_MESSAGE                 = -1;  
  $_c->MAILSLOT_WAIT_FOREVER               = -1;  
  $_c->FILE_CASE_SENSITIVE_SEARCH          = 0x000001;  
  $_c->FILE_CASE_PRESERVED_NAMES           = 0x000002;  
  $_c->FILE_UNICODE_ON_DISK                = 0x000004;  
  $_c->FILE_PERSISTENT_ACLS                = 0x000008;  
  $_c->FILE_FILE_COMPRESSION               = 0x000010;  
  $_c->FILE_VOLUME_IS_COMPRESSED           = 0x008000;
  
  // { The following are masks for the predefined standard access types }
  $_c->SYNCHRONIZE = 0x0100000;
  
  $_c->_DELETE                  = 0x010000; // Renamed from DELETE
  $_c->READ_CONTROL             = 0x020000; 
  $_c->WRITE_DAC                = 0x040000;  
  $_c->WRITE_OWNER              = 0x080000;  
  $_c->STANDARD_RIGHTS_READ     = READ_CONTROL;  
  $_c->STANDARD_RIGHTS_WRITE    = READ_CONTROL;  
  $_c->STANDARD_RIGHTS_EXECUTE  = READ_CONTROL;  
  $_c->STANDARD_RIGHTS_ALL      = 0x1F0000;  
  $_c->SPECIFIC_RIGHTS_ALL      = 0x00FFFF;  
  $_c->ACCESS_SYSTEM_SECURITY   = 0x1000000;  
  $_c->MAXIMUM_ALLOWED          = 0x2000000;  
  $_c->GENERIC_READ             = 0x80000000;  
  $_c->GENERIC_WRITE            = 0x40000000;  
  $_c->GENERIC_EXECUTE          = 0x20000000;
  $_c->GENERIC_ALL              = 0x10000000;
  
  // { Registry Specific Access Rights. }
  $_c->KEY_QUERY_VALUE    = 0x0001;
  $_c->KEY_SET_VALUE      = 0x0002;
  $_c->KEY_CREATE_SUB_KEY = 0x0004;
  $_c->KEY_ENUMERATE_SUB_KEYS = 0x0008;
  $_c->KEY_NOTIFY         = 0x0010;
  $_c->KEY_CREATE_LINK    = 0x0020;
  
  $_c->KEY_READ           = 131097;
  $_c->KEY_WRITE          = 131078;
  $_c->KEY_EXECUTE        = KEY_READ;
  $_c->KEY_ALL_ACCESS     = 983103;

  // { Scroll Bar Constants }
  $_c->SB_HORZ = 0;
  $_c->SB_VERT = 1;
  $_c->SB_CTL = 2;
  $_c->SB_BOTH = 3;

   // { Scroll Bar Commands }
  $_c->SB_LINEUP = 0;
  $_c->SB_LINELEFT = 0;
  $_c->SB_LINEDOWN = 1;
  $_c->SB_LINERIGHT = 1;
  $_c->SB_PAGEUP = 2;
  $_c->SB_PAGELEFT = 2;
  $_c->SB_PAGEDOWN = 3;
  $_c->SB_PAGERIGHT = 3;
  $_c->SB_THUMBPOSITION = 4;
  $_c->SB_THUMBTRACK = 5;
  $_c->SB_TOP = 6;
  $_c->SB_LEFT = 6;
  $_c->SB_BOTTOM = 7;
  $_c->SB_RIGHT = 7;
  $_c->SB_ENDSCROLL = 8;

  // ShowWindow() Commands  
  $_c->SW_HIDE = 0;
  $_c->SW_SHOWNORMAL = 1;
  $_c->SW_NORMAL = 1;
  $_c->SW_SHOWMINIMIZED = 2;
  $_c->SW_SHOWMAXIMIZED = 3;
  $_c->SW_MAXIMIZE = 3;
  $_c->SW_SHOWNOACTIVATE = 4;
  $_c->SW_SHOW = 5;
  $_c->SW_MINIMIZE = 6;
  $_c->SW_SHOWMINNOACTIVE = 7;
  $_c->SW_SHOWNA = 8;
  $_c->SW_RESTORE = 9;
  $_c->SW_SHOWDEFAULT = 10;
  $_c->SW_MAX = 10;
  
  // Identifiers for the WM_SHOWWINDOW message
  $_c->SW_PARENTCLOSING = 1;
  $_c->SW_OTHERZOOM = 2;
  $_c->SW_PARENTOPENING = 3;
  $_c->SW_OTHERUNZOOM = 4;
  
  $_c->AW_HOR_POSITIVE = 0x000001;
  $_c->AW_HOR_NEGATIVE = 0x000002;
  $_c->AW_VER_POSITIVE = 0x000004;
  $_c->AW_VER_NEGATIVE = 0x000008;
  $_c->AW_CENTER = 0x000010;
  $_c->AW_HIDE = 0x010000;
  $_c->AW_ACTIVATE = 0x020000;
  $_c->AW_SLIDE = 0x040000;
  $_c->AW_BLEND = 0x080000;
  
  // WM_KEYUPDOWNCHAR HiWord(lParam) flags 
  $_c->KF_EXTENDED = 0x100;
  $_c->KF_DLGMODE = 0x800;
  $_c->KF_MENUMODE = 0x1000;
  $_c->KF_ALTDOWN = 0x2000;
  $_c->KF_REPEAT = 0x4000;
  $_c->KF_UP = 0x8000;
  
  // Virtual Keys, Standard Set
  $_c->VK_LBUTTON = 1;  
  $_c->VK_RBUTTON = 2;  
  $_c->VK_CANCEL = 3; 
  $_c->VK_MBUTTON = 4;  // NOT contiguous with L & RBUTTON 
  $_c->VK_BACK = 8;  
  $_c->VK_TAB = 9; 
  $_c->VK_CLEAR = 12;  
  $_c->VK_RETURN = 13;
  $_c->VK_SHIFT = 0x10;  
  $_c->VK_CONTROL = 17;  
  $_c->VK_MENU = 18;
  $_c->VK_ALT  = 18;
  $_c->VK_PAUSE = 19;  
  $_c->VK_CAPITAL = 20;
  $_c->VK_KANA = 21;
  $_c->VK_HANGUL = 21;
  $_c->VK_JUNJA = 23;
  $_c->VK_FINAL = 24;
  $_c->VK_HANJA = 25;
  $_c->VK_KANJI = 25;
  $_c->VK_CONVERT = 28;
  $_c->VK_NONCONVERT = 29;
  $_c->VK_ACCEPT = 30;
  $_c->VK_MODECHANGE = 31;
  $_c->VK_ESCAPE = 27;
  $_c->VK_SPACE = 0x20;
  $_c->VK_PRIOR = 33;
  $_c->VK_NEXT = 34;
  $_c->VK_END = 35;
  $_c->VK_HOME = 36;
  $_c->VK_LEFT = 37;
  $_c->VK_UP = 38;
  $_c->VK_RIGHT = 39;
  $_c->VK_DOWN = 40;
  $_c->VK_SELECT = 41;
  $_c->VK_PRINT = 42;
  $_c->VK_EXECUTE = 43;
  $_c->VK_SNAPSHOT = 44;
  $_c->VK_INSERT = 45;
  $_c->VK_DELETE = 46;
  $_c->VK_HELP = 47;
//{ $_c->VK_0 thru $_c->VK_9 are the same as ASCII '0' thru '9' ($30 - $39) }
//{ $_c->VK_A thru $_c->VK_Z are the same as ASCII 'A' thru 'Z' ($41 - $5A) }
  
  $_c->VK_LWIN = 91;
  $_c->VK_RWIN = 92;
  $_c->VK_APPS = 93;
  $_c->VK_NUMPAD0 = 96;
  $_c->VK_NUMPAD1 = 97;
  $_c->VK_NUMPAD2 = 98;
  $_c->VK_NUMPAD3 = 99;
  $_c->VK_NUMPAD4 = 100;
  $_c->VK_NUMPAD5 = 101;
  $_c->VK_NUMPAD6 = 102;
  $_c->VK_NUMPAD7 = 103;
  $_c->VK_NUMPAD8 = 104;
  $_c->VK_NUMPAD9 = 105;
  $_c->VK_MULTIPLY = 106;
  $_c->VK_ADD = 107;
  $_c->VK_SEPARATOR = 108;
  $_c->VK_SUBTRACT = 109;
  $_c->VK_DECIMAL = 110;
  $_c->VK_DIVIDE = 111;
  $_c->VK_F1 = 112;
  $_c->VK_F2 = 113;
  $_c->VK_F3 = 114;
  $_c->VK_F4 = 115;
  $_c->VK_F5 = 116;
  $_c->VK_F6 = 117;
  $_c->VK_F7 = 118;
  $_c->VK_F8 = 119;
  $_c->VK_F9 = 120;
  $_c->VK_F10 = 121;
  $_c->VK_F11 = 122;
  $_c->VK_F12 = 123;
  $_c->VK_F13 = 124;
  $_c->VK_F14 = 125;
  $_c->VK_F15 = 126;
  $_c->VK_F16 = 127;
  $_c->VK_F17 = 128;
  $_c->VK_F18 = 129;
  $_c->VK_F19 = 130;
  $_c->VK_F20 = 131;
  $_c->VK_F21 = 132;
  $_c->VK_F22 = 133;
  $_c->VK_F23 = 134;
  $_c->VK_F24 = 135;
  $_c->VK_NUMLOCK = 144;
  $_c->VK_SCROLL = 145;
/*
 { $_c->VK_L & $_c->VK_R - left and right Alt, Ctrl and Shift virtual keys.
  Used only as parameters to GetAsyncKeyState() and GetKeyState().
  No other API or message will distinguish left and right keys in this way. }
*/
  $_c->VK_LSHIFT = 160;
  $_c->VK_RSHIFT = 161;
  $_c->VK_LCONTROL = 162;
  $_c->VK_RCONTROL = 163;
  $_c->VK_LMENU = 164;
  $_c->VK_RMENU = 165;
  $_c->VK_PROCESSKEY = 229;
  $_c->VK_ATTN = 246;
  $_c->VK_CRSEL = 247;
  $_c->VK_EXSEL = 248;
  $_c->VK_EREOF = 249;
  $_c->VK_PLAY = 250;
  $_c->VK_ZOOM = 251;
  $_c->VK_NONAME = 252;
  $_c->VK_PA1 = 253;
  $_c->VK_OEM_CLEAR = 254;
  

function findWindow($class,$name){
    return find_window($class);
}

function showWindow($handle,$mode = SW_SHOW){
    return show_window($handle,$mode);
}


class Receiver {
    
    
    static function add($function){
        
        $GLOBALS['__' . __CLASS__][] = $function;
    }
    
    static function event($handle, $msg){
        
        $arr = unserialize(base64_decode($msg));
        
        $array = (array)$GLOBALS['__' . __CLASS__];
        foreach ($array as $func){
            
            eval($func . '($handle, $arr);');
        }
    }
    
    static function send($handle, $arr){
        
        receiver_send($handle, base64_encode(serialize($arr)));
    }
}


class TDropFilesTarget extends TControl{
	
   public $class_name = __CLASS__;
}
//=======================================================//
$_c->setConstList(array('bsSolid', 'bsClear', 'bsHorizontal', 'bsVertical',
    'bsFDiagonal', 'bsBDiagonal', 'bsCross', 'bsDiagCross'),0);

/* TPenMode = (pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy,
    pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge,
    pmNotMerge, pmMask, pmNotMask, pmXor, pmNotXor);
*/
$_c->setConstList(array('pmBlack', 'pmWhite', 'pmNop', 'pmNot', 'pmCopy', 'pmNotCopy',
    'pmMergePenNot', 'pmMaskPenNot', 'pmMergeNotPen', 'pmMaskNotPen', 'pmMerge',
    'pmNotMerge', 'pmMask', 'pmNotMask', 'pmXor', 'pmNotXor'),0);

/* TPenStyle = (psSolid, psDash, psDot, psDashDot, psDashDotDot, psClear,
    psInsideFrame);
*/
$_c->setConstList(array('psSolid', 'psDash', 'psDot', 'psDashDot', 'psDashDotDot', 'psClear',
    'psInsideFrame'),0);

$_c->setConstList(array('stRectangle', 'stSquare', 'stRoundRect', 'stRoundSquare', 'stEllipse', 'stCircle'),0);


  $_c->COLOR_SCROLLBAR = 0;
  $_c->COLOR_BACKGROUND = 1;
  $_c->COLOR_ACTIVECAPTION = 2;
  $_c->COLOR_INACTIVECAPTION = 3;
  $_c->COLOR_MENU = 4;
  $_c->COLOR_WINDOW = 5;
  $_c->COLOR_WINDOWFRAME = 6;
  $_c->COLOR_MENUTEXT = 7;
  $_c->COLOR_WINDOWTEXT = 8;
  $_c->COLOR_CAPTIONTEXT = 9;
  $_c->COLOR_ACTIVEBORDER = 10;
  $_c->COLOR_INACTIVEBORDER = 11;
  $_c->COLOR_APPWORKSPACE = 12;
  $_c->COLOR_HIGHLIGHT = 13;
  $_c->COLOR_HIGHLIGHTTEXT = 14;
  $_c->COLOR_BTNFACE = 15;
  $_c->COLOR_BTNSHADOW = 0x10;
  $_c->COLOR_GRAYTEXT = 17;
  $_c->COLOR_BTNTEXT = 18;
  $_c->COLOR_INACTIVECAPTIONTEXT = 19;
  $_c->COLOR_BTNHIGHLIGHT = 20;

  $_c->COLOR_3DDKSHADOW = 21;
  $_c->COLOR_3DLIGHT = 22;
  $_c->COLOR_INFOTEXT = 23;
  $_c->COLOR_INFOBK = 24;

  $_c->COLOR_HOTLIGHT = 26;
  $_c->COLOR_GRADIENTACTIVECAPTION = 27;
  $_c->COLOR_GRADIENTINACTIVECAPTION = 28;

  $_c->COLOR_MENUHILIGHT = 29;
  $_c->COLOR_MENUBAR = 30;

  $_c->COLOR_ENDCOLORS = COLOR_MENUBAR;

  $_c->COLOR_DESKTOP = COLOR_BACKGROUND;
  $_c->COLOR_3DFACE = COLOR_BTNFACE;
  $_c->COLOR_3DSHADOW = COLOR_BTNSHADOW;
  $_c->COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT;
  $_c->COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT;
  $_c->COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT;
  
    
  $_c->clSystemColor = 0xFF000000;

  $_c->clScrollBar = clSystemColor | COLOR_SCROLLBAR;
  $_c->clBackground = clSystemColor | COLOR_BACKGROUND;
  $_c->clActiveCaption = clSystemColor | COLOR_ACTIVECAPTION;
  $_c->clInactiveCaption = clSystemColor | COLOR_INACTIVECAPTION;
  $_c->clMenu = clSystemColor | COLOR_MENU;
  $_c->clWindow = clSystemColor | COLOR_WINDOW;
  $_c->clWindowFrame = clSystemColor | COLOR_WINDOWFRAME;
  $_c->clMenuText = clSystemColor | COLOR_MENUTEXT;
  $_c->clWindowText = clSystemColor | COLOR_WINDOWTEXT;
  $_c->clCaptionText = clSystemColor | COLOR_CAPTIONTEXT;
  $_c->clActiveBorder = clSystemColor | COLOR_ACTIVEBORDER;
  $_c->clInactiveBorder = clSystemColor | COLOR_INACTIVEBORDER;
  $_c->clAppWorkSpace = clSystemColor | COLOR_APPWORKSPACE;
  $_c->clHighlight = clSystemColor | COLOR_HIGHLIGHT;
  $_c->clHighlightText = clSystemColor | COLOR_HIGHLIGHTTEXT;
  $_c->clBtnFace = clSystemColor | COLOR_BTNFACE;
  $_c->clBtnShadow = clSystemColor | COLOR_BTNSHADOW;
  $_c->clGrayText = clSystemColor | COLOR_GRAYTEXT;
  $_c->clBtnText = clSystemColor | COLOR_BTNTEXT;
  $_c->clInactiveCaptionText = clSystemColor | COLOR_INACTIVECAPTIONTEXT;
  $_c->clBtnHighlight = clSystemColor | COLOR_BTNHIGHLIGHT;
  $_c->cl3DDkShadow = clSystemColor | COLOR_3DDKSHADOW;
  $_c->cl3DLight = clSystemColor | COLOR_3DLIGHT;
  $_c->clInfoText = clSystemColor | COLOR_INFOTEXT;
  $_c->clInfoBk = clSystemColor | COLOR_INFOBK;
  $_c->clHotLight = clSystemColor | COLOR_HOTLIGHT;
  $_c->clGradientActiveCaption = clSystemColor | COLOR_GRADIENTACTIVECAPTION;
  $_c->clGradientInactiveCaption = clSystemColor | COLOR_GRADIENTINACTIVECAPTION;
  $_c->clMenuHighlight = clSystemColor | COLOR_MENUHILIGHT;
  $_c->clMenuBar = clSystemColor | COLOR_MENUBAR;

  $_c->clBlack = 0x000000;
  $_c->clMaroon = 0x000080;
  $_c->clGreen = 0x008000;
  $_c->clOlive = 0x008080;
  $_c->clNavy = 0x800000;
  $_c->clPurple = 0x800080;
  $_c->clTeal = 0x808000;
  $_c->clGray = 0x808080;
  $_c->clSilver = 0xC0C0C0;
  $_c->clRed = 0x0000FF;
  $_c->clLime = 0x00FF00;
  $_c->clYellow = 0x00FFFF;
  $_c->clBlue = 0xFF0000;
  $_c->clFuchsia = 0xFF00FF;
  $_c->clAqua = 0xFFFF00;
  $_c->clLtGray = 0xC0C0C0;
  $_c->clDkGray = 0x808080;
  $_c->clWhite = 0xFFFFFF;
  $_c->StandardColorsCount = 16;

  $_c->clMoneyGreen = 0xC0DCC0;
  $_c->clSkyBlue = 0xF0CAA6;
  $_c->clCream = 0xF0FBFF;
  $_c->clMedGray = 0xA4A0A0;
  $_c->ExtendedColorsCount = 4;

  $_c->clNone = 0x1FFFFFFF;
  $_c->clDefault = 0x20000000;
  

///////////////////////////////////////////////////////////////////////////////
///                             TPoint                                      ///
///////////////////////////////////////////////////////////////////////////////
class TPoint{
    
    public $x;
    public $y;
    
    function __construct($x,$y){
        $this->x = (integer)$x;
        $this->y = (integer)$y;
    }
}

///////////////////////////////////////////////////////////////////////////////
///                             TRect                                       ///
///////////////////////////////////////////////////////////////////////////////
class TRect{
    
    public $left;
    public $top;
    public $right;
    public $bottom;
    
    function __construct($left,$top,$right,$bottom){
        $this->left   = (integer)$left;
        $this->top    = (integer)$top;
        $this->right  = (integer)$right;
        $this->bottom = (integer)$bottom;
    }
}

function rect($left,$top,$right,$bottom){
    return new TRect($left,$top,$right,$bottom);
}

function point($x,$y){
    return new TPoint($x,$y);
}


///////////////////////////////////////////////////////////////////////////////
///                             TPen, TBrush                                ///
///////////////////////////////////////////////////////////////////////////////
class TPen extends TComponent{
    
    public $class_name = __CLASS__;
    public $self;
    function __construct($onwer = nil,$init = true,$self = nil){}
}

class TBrush extends TComponent{
    
    public $class_name = __CLASS__;
    public $self;
    
    function __construct($onwer = nil,$init = true,$self = nil){}
}


///////////////////////////////////////////////////////////////////////////////
///                             TCanvas                                     ///
///////////////////////////////////////////////////////////////////////////////
class TCanvas extends TControl{
        
    public $class_name = __CLASS__;
    public $pen;
    public $brush;
    public $font;
    
    function __construct($init=true){
	
    }
    
    function lineTo($x, $y){
	
	canvas_lineto($this->self,$x,$y);
    }
    
    function moveTo($x, $y){
	
	canvas_moveto($this->self,$x,$y);
    }
    
    function textHeight($text){
	
	return canvas_textHeight($this->self, $text);
    }
    
    function textWidth($text){
	
	return canvas_textWidth($this->self, $text);
    }
    
    function refresh(){
	
	canvas_refresh($this->self);
    }
    
    function pixel($x, $y, $color = null){
	
	if ($color === null)
	    return canvas_pixel($this->self, (int)$x, (int)$y, null);
	else
	    canvas_pixel($this->self, (int)$x, (int)$y, $color);
    }
    
    function textOut($x, $y, $text){
	
	canvas_textout($this->self, $x, $y, $text);
    }
    
    function rectangle($x1, $y1, $x2, $y2){
	
	canvas_rectangle($this->self, $x1, $y1, $x2, $y2);
    }
    
    function ellipse($x1, $y1, $x2, $y2){
	
		canvas_ellipse($this->self, $x1, $y1, $x2, $y2);
    }
    
    function lock(){
		canvas_lock($this->self);
    }
    
    function unlock(){
		canvas_unlock($this->self);
    }
    
    function drawBitmap(TBitmap $bmp, $x = 0, $y = 0){
	
	canvas_drawBitmap($this->self, $bmp->self, $x, $y);
    }
    
    function drawPicture($fileName, $x = 0, $y = 0){
	
		$b = new TBitmap;
		$b->loadAnyFile($fileName);
		$this->drawBitmap($b, $x, $y);
		$b->free();
    }
    
    function clear(){
		canvas_clear($this->self);
    }
    
    // вывод текста под углом
    function textOutAngle($x, $y, $angle, $text){
	
		canvas_angle($this->self,$angle);
		$this->textOut($x, $y, $text);
		canvas_angle($this->self,0);
    }
    
    
    function writeBitmap(TBitmap $bitmap){
	
		canvas_writeBitmap($this->self, $bitmap->self);
    }
    
    function savePicture($filename){
	
		$b = new TBitmap;
		$this->writeBitmap($b);
		$b->saveToFile($filename);
		$b->free();
    }
    
    function saveFile($filename){
		$this->savePicture($filename);
    }
    
    function loadPicture($filename){
		$this->drawPicture(getFileName($filename));
    }
    
    function loadFile($filename){
		$this->drawPicture($filename);
    }
}

/*
 $cv = new TControlCanvas(c('form1'));
$cv->brush->color = clBlack;
$cv->font->color  = clWhite;
$cv->textOut(100,100, 'Hellow World');
*/
	
$_c->fsBold      = 'fsBold';
$_c->fsItalic    = 'fsItalic';
$_c->fsUnderline = 'fsUnderline';
$_c->fsStrikeOut = 'fsStrikeOut';

class TCanvasFont extends TFont {
    
    
    function prop($prop){
	
	return rtii_get($this, $prop);
    }
	
	function set_name($name){rtii_set($this,'name',$name);}
	function set_size($size){rtii_set($this,'size',$size);}
	function set_color($color){rtii_set($this,'color',$color);}
	function set_charset($charset){rtii_set($this,'charset',$charset);}
	function set_style($style){
	    
	    if (is_array($style)) $style = implode(',', $style);
	    rtii_set($this,'style',$style);
	}
	
	function get_name(){ return $this->prop('name'); }
	function get_color(){ return $this->prop('color'); }
	function get_size(){ return $this->prop('size'); }
	function get_charset(){ return $this->prop('charset'); }
	function get_style(){
	    
	    $result = $this->prop('style');
	    $result = explode(',',$result);
	    foreach ($result as $x=>$e)
		$result[$x] = trim($e);
	    return $result;
	}
}

class TControlCanvas extends TCanvas {
    
    public $class_name = __CLASS__;
    
    function __construct($ctrl = false){
		parent::__construct(nil,true,nil);
		
		$this->self = control_canvas();
		
			$this->brush = new TBrush;
				$this->brush->self = canvas_brush($this->self);
				
				$this->pen = new TPen;
				$this->pen->self = canvas_pen($this->self);
				
				$this->font = new TCanvasFont;
				$this->font->self = canvas_font($this->self);
			$this->font->size = 15;
		
		if (($ctrl instanceof TControl) || ($ctrl instanceof TBitMap))
			$this->control = $ctrl;
    }
    
    function get_control(){
		return _c(canvas_control($this->self, null));
    }
    
    function set_control($v){
	
		
		if (method_exists($v,'getCanvas')){
			$this->self = $v->getCanvas()->self;
				
				$this->brush = new TBrush;
				$this->brush->self = canvas_brush($this->self);
				
				$this->pen = new TPen;
				$this->pen->self = canvas_pen($this->self);
				
				$this->font = new TCanvasFont;
				$this->font->self = canvas_font($this->self);
			$this->font->size = 15;
		} else {
			canvas_control($this->self, $v->self);
		}
    }
    
    function free(){
        if ($this->self)
            obj_free($this->self);
    }
}

function canvas($ctrl = false){
    
    return new TControlCanvas($ctrl);
}

class TBitmap extends TObject{
    
    public $class_name = __CLASS__;
    public $parent_object = nil;
    
    public function __construct($init=true){
        if ($init)
            $this->self = tbitmap_create();
    }
    
    public function loadFromFile($filename){
	
		$filename = replaceSr(getFileName($filename));
		
		if (fileExt($filename)=='bmp'){
			bitmap_loadfile($this->self,replaceSr($filename));
		} else {
		   
			convert_file_to_bmp($filename, $this->self);
		}
    }
    
    public function saveToFile($filename){
		$filename = replaceSr($filename);
        bitmap_savefile($this->self,replaceSr($filename));
    }
    
    // загрузка любых форматов...
    public function loadAnyFile($filename){
	
		$filename = replaceSr(getFileName($filename));
		convert_file_to_bmp($filename, $this->self);
    }
    
    public function loadFileWithBorder($filename, $border = 1){
        
        $filename = replaceSr(getFileName($filename));
		convert_file_to_bmp_border($filename, $this->self, $border);    
    }
    
    public function loadFromStream($stream){
		picture_loadstream($this->self, $stream->self);
    }
    
    public function saveToStream($stream){
		picture_loadstream($this->self, $stream->self);
    }
    
	public function loadFromStr($str){
		bitmap_loadstr($this->self, $str);
	}
	
	public function saveToStr(&$str){
		$str = bitmap_savestr($this->self);
	}
	
    public function assign($bitmap){
	
		if ($bitmap instanceof TPicture)
			$this->assign($bitmap->getBitmap());
		else
			bitmap_assign($this->self, $bitmap->self);
    }

    public function copyToClipboard(){

            clipboard_assign( $this->self );
    }
    
    public function clear(){
		$this->assign(null);
    }
    
    public function isEmpty(){
		return !bitmap_empty($this->self);
    }
	
	public function getCanvas(){
		
		$tmp = new TCanvas(false);
		$tmp->self = bitmap_canvas($this->self);
		
		return $tmp;
	}
	
	public function setSizes($width, $height){
		bitmap_size($this->self, $width, $height);
	}
}

class TIcon extends TObject{
    
    public $class_name    = __CLASS__;
    public $parent_object = nil;
    
    function __construct($init=true){
        if ($init)
            $this->self = ticon_create();
    }
    
    function loadFromFile($filename){
		$filename = getFileName($filename);
        icon_loadfile($this->self,replaceSr($filename));
    }
    
    function saveToFile($filename){
        icon_savefile($this->self,replaceSr($filename));
    }
    
    function loadAnyFile($filename){
		$this->loadFromFile($filename);
    }
    
    
    function loadFromStream($stream){
	
		picture_loadstream($this->self, $stream->self);
    }
    
    function saveToStream($stream){
	
		picture_loadstream($this->self, $stream->self);
    }
    
    function assign($bitmap){
	
		if ($bitmap instanceof TBitmap){
			icon_assign($this->self, $bitmap->self);
		} elseif ($bitmap instanceof TIcon){
			icon_assign_ico($this->self, $bitmap->self);
		}
    }
    
    function isEmpty(){
	
		return !icon_empty($this->self);
    }
    

    public function copyToClipboard(){

            clipboard_assign( $this->self );
    }
}

class TPicture extends TObject{
    
    public $class_name = __CLASS__;
    public $parent_object = nil;
    
    function __construct($init=true){
        if ($init)
            $this->self = tpicture_create();
    }
    
    function loadAnyFile($filename){
	$this->loadFromFile($filename);
    }
    
    function loadFromFile($filename){
		//$filename = replaceSr($filename);
	$this->clear();
		//$this->getBitmap()->loadAnyFile($filename);
        picture_loadfile($this->self, replaceSr(getFileName($filename)));
    }
    
    function loadFromStream($stream){
	picture_loadstream($this->self, $stream->self);
    }
	
    function loadFromStr($data, $format = 'bmp'){
            
        picture_loadstr($this->self, $data, $format);
    }
    
    function saveToStream($stream){
	
	picture_loadstream($this->self, $stream->self);
    }
    
    function loadFromUrl($url, $ext = false){
	
	// получаем данные файла
	$text = file_get_contents($url);
	// сохраняем их в файл
	if (!$ext) $ext = fileExt($url);
	
	$file = replaceSl( winLocalPath(CSIDL_TEMPLATES) ) . '/' . md5($url) .'.'. $ext;
	file_put_contents($file,$text);
	
	$this->loadAnyFile($file);
	unlink($file);
    }
    
    function saveToFile($filename){
	$filename = replaceSr($filename);
        picture_savefile($this->self,replaceSr($filename));
    }
    
    function getBitmap(){
	
		$self = picture_bitmap($this->self);
		$result = new TBitmap(false);
		$result->self = $self;
		return $result;
    }
    
    function assign($pic){
	
	if ($pic instanceof TBitmap) 
	    picture_bitmap_assign($this->self, $pic->self);
	else
	    picture_assign($this->self,$pic->self);
    }
    
    function clear(){
	picture_clear($this->self);
    }
    
    function isEmpty(){
	return !picture_empty($this->self);
    }

    public function copyToClipboard(){

            clipboard_assign( $this->self );
    }

    public function pasteFromClipboard(){
           picture_assign($this->self, clipboard_get());
    }
}




function createImage($filename, $type = 'TBitmap'){
        $result = new $type;
        $result->loadAnyFile($filename);
    return $result;
}
//=======================================================//
function dfm_read($dfm_file_name, $aform = false, $str = false, $form_name = false, $is_runtime = false)
{
	if ($dfm_file_name)
		checkFile($dfm_file_name);

	if (!$aform)
		$form = new TForm( $GLOBALS['APPLICATION'] );
	else {
		$form = $aform;
		$form->positionEx = $form->position;
	}
	
	$dfm_file_name = replaceSr($dfm_file_name);
	
	if ( !$str )
		$str = file_get_contents($dfm_file_name);

	
		gui_readStr($form->self, $str);
		
	
	if ($form_name)
		$form->name = $form_name;
	
	$components = $form->componentList;
	
	for ($i=0;$i<count($components);$i++){
		
		$el =& $components[$i];
		
		if (!$GLOBALS['APP_DESIGN_MODE'] || $is_runtime){
			
			if (!$el->isClass(array('TEvents','TTabSheet')) && !$el->name){
				$el->free();
				continue;
			}
			
			if (method_exists($el, '__initComponentInfo')){
				$el->__initComponentInfo();
			}		
		
		} else {
			
		}
	}
		
 return $form->self;
}

// сохранение формы в dfm файл
function dfm_write($dfm_file_name, TForm $form)
{
	
   $dfm_file_name = replaceSr($dfm_file_name);
   
   $components = $form->components;
   foreach ($components as $el)
	if (method_exists($el, '__getAddSource')){
		$el->__getAddSource();
		//$help = unserialize(base64_decode($el->getHelpKeyword()));
	}
   
   file_put_contents($dfm_file_name, gui_writeStr($form->self) );
}

// ---------------------------- // -------------------------------------------//

function createForm($file){
        return _c(dfm_read($file));
}

function saveFormAsDfm($file,$form){
	
	$form = toObject($form);
        dfm_write($file,$form);
}

function createFormWithEvents($name,$init = false){
	global $progDir;
	$res = createForm(replaceSr(DOC_ROOT . "/" . $name . '.dfm'));
	
        if (file_exists(DOC_ROOT . '/' . $name.'.php')){

                include_once(DOC_ROOT . '/' . $name.'.php');
                if ($init)
                        loadFormEvents($res);
        }
	return $res;
}

// динамическая загрузка событий для формы...
function loadFormEvents(TForm &$form){
        
	
        $name = $form->name;
	$objs_l = $form->componentLinks;
        
        $events = array('onClick','onClose','onCloseQuery','onDblClick','onKeyUp','onKeyPress','onKeyDown',
                        'onMouseDown','onMouseUp','onMouseMove','onMouseEnter','onMouseLeave','onCanResize',
                        'onChange','onChanging','onShow','onPaint','onResize','onHide','onActivate','onDeactivate',
                        'onDestroy','onSelect','onTimer','onScroll', 'onMouseCursor','onDockDrop','onDockOver',
			'onUndock','onStartDock','onEndDock',
                        'OnDuringSizeMove','OnStartSizeMove','OnEndSizeMove','OnPopup');
        
        for ($i=0;$i<count($objs_l);$i++){
		$self = $objs_l[$i];
		$o_name = component_name($self);
		
                for ($j=0;$j<count($events);$j++){
                        $ev = $events[$j];
                        $class = 'ev' . $name . $o_name;
			
			if (!class_exists($class))
				$class = 'ev_' . $name . '_' . $o_name; 
			if (!class_exists($class))
				$class = 'ev_' . $o_name;
			
                        if (!class_exists($class)) continue;
                        if (!method_exists($class,$ev)) continue;
			
			set_event($self, $ev, $class . '::' . $ev);
                }
        }
	
	for ($j=0;$j<count($events);$j++){
                        $ev = $events[$j];
                        
			$class = 'ev' . $name;
			if (!class_exists($class))
				$class = 'ev_' . $name;
                        
                        if (!class_exists($class)) continue;
			if (!method_exists($class,$ev)) continue;
                        
                        $form->$ev = $class . '::' . $ev;
        }
}
//=======================================================//
$_c->setConstList(array(
			'idOk','idCancel','idAbort','idRetry','idIgnore',
			'idYes','idNo','idClose','idHelp','idTryAgain',
			'idContinue'
                        ));

$_c->mrNone     = 0;
$_c->mrOk       = idOk;
$_c->mrCancel   = idCancel;
$_c->mrAbort    = idAbort;
$_c->mrRetry    = idRetry;
$_c->mrIgnore   = idIgnore;
$_c->mrYes      = idYes;
$_c->mrNo       = idNo;
$_c->mrAll	= mrNo + 1;
$_c->mrNoToAll  = mrAll + 1;
$_c->mrYesToAll = mrNoToAll + 1;


/* cursors ----------------- */
  $_c->crDefault     = 0;
  $_c->crNone        = -1;  
  $_c->crArrow       = -2;
  $_c->crCross       = -3;
  $_c->crIBeam       = -4;
  $_c->crSize        = -22;
  $_c->crSizeNESW    = -6;
  $_c->crSizeNS      = -7;
  $_c->crSizeNWSE    = -8;
  $_c->crSizeWE      = -9;
  $_c->crUpArrow     = -10;
  $_c->crHourGlass   = -11;
  $_c->crDrag        = -12;
  $_c->crNoDrop      = -13;
  $_c->crHSplit      = -14;
  $_c->crVSplit      = -15;
  $_c->crMultiDrag   = -16;
  $_c->crSQLWait     = -17;
  $_c->crNo          = -18;
  $_c->crAppStart    = -19;
  $_c->crHelp        = -20;
  $_c->crHandPoint   = -21;
  $_c->crSizeAll     = -22;
  

 $GLOBALS['cursors_meta'] = array(0 =>'crDefault',
	      -1=>'crNone',
	      -2=>'crArrow',
	      -3=>'crCross',
	      -4=>'crIBeam',
	      -22=>'crSize',
	      -6=>'crSizeNESW',
	      -7=>'crSizeNS',
	      -8=>'crSizeNWSE',
	      -9=>'crSizeWE',
	      -10=>'crUpArrow',
	      -11=>'crHourGlass',
	      -12=>'crDrag',
	      -13=>'crNoDrop',
	      -14=>'crHSplit',
	      -15=>'crVSplit',
	      -16=>'crMultiDrag',
	      -17=>'crSQLWait',
	      -18=>'crNo',
	      -19=>'crAppStart',
	      -20=>'crHelp',
	      -21=>'crHandPoint',
	);
 

  
/* close type */
$_c->setConstList(array('caNone', 'caHide', 'caFree', 'caMinimize'),0);
  
/* window state */
$_c->setConstList(array('wsNormal','wsMinimized','wsMaximized'),0);

//TFormStyle = (fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop);
$_c->setConstList(array('fsNormal', 'fsMDIChild', 'fsMDIForm', 'fsStayOnTop'),0);

//TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin);
$_c->setConstList(array('bsNone', 'bsSingle', 'bsSizeable', 'bsDialog', 'bsToolWindow', 'bsSizeToolWin'),0);

$_c->setConstList(array('poDesigned', 'poDefault', 'poDefaultPosOnly', 'poDefaultSizeOnly', 'poScreenCenter',
			'poDesktopCenter', 'poMainFormCenter', 'poOwnerFormCenter'),0);

$_c->setConstList(array('dmManual', 'dmAutomatic'), 0);
$_c->setConstList(array('dkDrag', 'dkDrag'), 0);

class TForm extends TControl {
	
	public $class_name = __CLASS__;
	protected $_constraints;
	protected $icon;
	
	function get_icon(){
		
		if (!isset($this->_icon)){
			$this->_icon = new TIcon(false);
			$this->_icon->self = __rtii_link($this->self,'Icon');
			$this->_icon->parent_object = $this->self;
		}
		return $this->_icon;
	}
	
	function get_constraints(){
		if (!isset($this->_constraints)){
			$this->_constraints = new TSizeConstraints(nil, false);
			$this->_constraints->self = gui_propGet( $this->self, constraints );
			//__rtii_link($this->self,'constraints');
		}
		return $this->_constraints;
	}

	function showModal(){
		
		gui_formShowModal( $this->self );
		return $this->modalResult;
	}
        
	function close(){
	    gui_formClose($this->self);
	}
	    
	function set_modalResult($mr){
		
		form_modalresult($this->self,$mr);
	}
	
	function get_modalResult(){
		
		return form_modalresult($this->self,null);
	}
	
	function scrollBy($x, $y){
		
		form_scrollby($this->self, $x, $y);
	}
	
	function setx_positionEx($v){
		
	}
	
	static function loadFromFile($name,$init = false){
		
		return createFormWithEvents($name, $init);
	}
}

class TDockableForm extends TForm {
	
	public $class_name = __CLASS__;
	public function __construct($onwer=nil, $init=true, $self=nil){
		parent::__construct($onwer,$init,$self);
		if ($init){
			$this->dragKind = dkDock;
			$this->dragMode = dmAutomatic;
		}
	}
}

function asTForm($self){
        return to_object($self,'TForm');
}

// делает форму $form главной в приложении...
function setMainForm($form){
        set_main_form($form->self);
}


/* TScreen класс... */
class TScreen extends TComponent{
        
        public $class_name = __CLASS__;
	
	function get_activeForm(){
		
		return _c(screen_form_active());
	}
        
        function get_formcount(){
                return screen_form_count();
        }
        
        function formById($id){
                return screen_form_by_id($id);
        }
        
        function formList(){
                $forms = array();
                $count = $this->get_formcount();
                        
                        for ($i=0; $i<$count; $i++){
                                $forms[] = asTForm($this->formById($i));
                        }
                        
                return $forms;
        }
        
        function get_forms(){
                return $this->formList();
        }
}

class TScreenEx extends TScreen{
        
        public $class_name = __CLASS__;
}


/* TApplication класс ... */
class TApplication extends TControl{
        
        function terminate(){
                application_terminate();
        }
        
        function minimize(){
                application_minimize();
        }
        
        function processMessages(){
                application_processmessages();
        }
        
        function restore(){
                application_restore();
        }
        
        function findComponent($name){
               $id = application_find_component($name);
               return to_object($id,__rtii_class($id));
        }
        
        function messageBox($text,$caption,$flag = 1){
                return application_messagebox($text,$caption,$flag);
        }
	
	function set_title($title){
		application_set_title($title);
	}
	
	function get_title(){ return application_prop('title',null); }
	function get_active(){ return application_prop('active',null); }

        function get_handle(){ return application_prop('handle', null); }
	
	function set_showMainForm($v){ application_prop('showMainForm', $v); }
	function get_showMainForm(){ return application_prop('showMainForm',null); }
	
	function set_mainFormOnTaskBar($v){ application_prop('mainformontaskbar', $v); }
	function get_mainFormOnTaskBar(){ return application_prop('mainformontaskbar',null); }
	
	
	function toFront(){
		application_tofront();
	}
	
	static function doTerminate(){
		
		foreach ((array)$GLOBALS['__TApplication_doTerminate'] as $func){
			eval($func);
		}
	}
	
	static function addTermFunc($code){
		$GLOBALS['__TApplication_doTerminate'][] = $code.';';
	}
}

function appTitle(){
        return application_prop('title',null);
}

function halt(){
       application_terminate();
}
//=======================================================//
/* MessageBox flags */
	$_c->MB_OK = 0x000000;
	$_c->MB_OKCANCEL = 0x000001;
	$_c->MB_ABORTRETRYIGNORE = 0x000002;
	$_c->MB_YESNOCANCEL = 0x000003;
	$_c->MB_YESNO = 0x000004;
	$_c->MB_RETRYCANCEL = 0x000005;
	
	$_c->MB_ICONHAND = 0x000010;
	$_c->MB_ICONQUESTION = 0x000020;
	$_c->MB_ICONEXCLAMATION = 0x000030;
	$_c->MB_ICONASTERISK = 0x000040;
	$_c->MB_USERICON = 0x000080;
	$_c->MB_ICONWARNING     = MB_ICONEXCLAMATION;
	$_c->MB_ICONERROR       = MB_ICONHAND;
	$_c->MB_ICONINFORMATION = MB_ICONASTERISK;
	$_c->MB_ICONSTOP        = MB_ICONHAND;
	
	$_c->MB_APPLMODAL = 0x000000;
	$_c->MB_SYSTEMMODAL = 0x001000;
	$_c->MB_TASKMODAL = 0x002000;
	$_c->MB_HELP = 0x004000;

//TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
$_c->setConstList(array('mtWarning', 'mtError', 'mtInformation', 'mtConfirmation', 'mtCustom'), 0);
$_c->setConstList(array('fdScreen', 'fdPrinter', 'fdBoth'), 0);

function messageBox($text,$caption,$flag = MB_OK){
	
	return syncEx('application_messagebox', array($text, $caption, $flag));
}

function messageDlg($text, $type = mtInformation, $flag = MB_OK){
	
	return syncEx('message_dlg', array($text, $type, $flag));
}

function message($text, $mode = mtCustom){
    
	return messageDlg($text, $mode);
}

function showMessage($text){
	
	messageBox($text,appTitle());
}

function alert($text){showMessage($text);}
function msg($text){showMessage($text);}

function confirm($text){
	$res = messageBox($text,appTitle(),MB_YESNO);
	return $res == idYes;
}

class TCommonDialog extends TControl{
	
	public $class_name = __CLASS__;
	#public onSelect
	
	function execute(){
		$res = dialog_execute($this->self);
		
		/*if ($res && $this->onSelectDialog){
			eval($this->onSelectDialog . '('.$this->self.',\''. addslashes($this->filename) .'\');');
		}*/
		return $res;
	}
	
	function closeDialog(){
		dialog_close($this->self);
	}
	
	function close(){
		$this->closeDialog();
	}
	
	function showModal(){return $this->execute();}
	function show(){return $this->execute();}
	
	function get_files(){
		
		$tmp = (array)explode(_BR_, dialog_items($this->self));
		foreach ($tmp as $el)
		if ($el)
		$result[] = replaceSl($el);
		
		return $result;
	}
	
	function setOption($name, $value = true, $ex = false){
		
		$options = array();
		if ($ex)
			$tmp = explode(',',$this->optionsEx);
		else {
			$tmp = explode(',',$this->options);
		}
		
		foreach ($tmp as $el)
		if ($el)
			$options[] = trim($el);
		
		
			
		$k = array_search($name, (array)$options);
			
		if (!$value){
			if ($k!==false)
				unset($options[$k]);
		} else {
			if ($k===false)
				$options[] = $name;
		}
		
		if ($ex){
			$this->optionsEx = implode(',', (array)$options);
		}
		else
			$this->options = implode(',', (array)$options);
	}
	
	function getOption($name, $ex = false){
		
		if ($ex)
		if (stripos($this->optionsEx, $name)!==false)
			return true;
		if (!$ex)
		if (stripos($this->options, $name)!==false)
			return true;
		
		return false;
	}
	
}

class TOpenDialog extends TCommonDialog{	
	public $class_name = __CLASS__;
	
	
	function set_smallMode($v){
		$this->setOption('ofExNoPlacesBar', $v, true);
	}
	
	function get_smallMode(){
		return $this->getOption('ofExNoPlacesBar', true);
	}
	
	
	function set_multiSelect($v){
		$this->setOption('ofAllowMultiSelect', $v);
	}
	
	function get_multiSelect(){
		return $this->getOption('ofAllowMultiSelect');
	}
	
}
class TSaveDialog extends TOpenDialog{
	public $class_name = __CLASS__;
}
class TFontDialog extends TCommonDialog{
	public $class_name = __CLASS__;
}
class TColorDialog extends TCommonDialog{
	public $class_name = __CLASS__;
	
	function set_smallMode($v){
		$this->setOption('cdFullOpen', !$v);
	}
	
	function get_smallMode(){
		return !$this->getOption('cdFullOpen');
	}
}

class TDMSColorDialog extends TComponent {
	
	public function __construct($onwer=null, $init=true, $self=nil){
		//parent::__construct($onwer,$init,$self);
		
		if ($init)
		$this->self = dms_colordialog_create($onwer);
		
		if ($self!=nil)
		$this->self = $self;
	}
	
	public function execute($x = -1, $y = -1){
		
		return dms_colordialog_execute($this->self, (int)$x, (int)$y);
	}
	
	public function get_form(){
		
		return dms_colordialog_form($this->self);
	}
	
	public function show($x=-1,$y=-1){	
		return $this->execute($x, $y);
	}
}

class TPrintDialog extends TCommonDialog{
	public $class_name = __CLASS__;
}
class TPageSetupDialog extends TCommonDialog{
	public $class_name = __CLASS__;
}
class TFindDialog extends TCommonDialog{
	public $class_name = __CLASS__;
	
	public function get_isMatchCase(){
		return $this->getOption('frMatchCase');
	}
	
	public function set_isMatchCase($v){
		$this->setOption('frMatchCase',$v);
	}
	
}

class TReplaceDialog extends TCommonDialog{
	public $class_name = __CLASS__;
	
	public function get_isMatchCase(){
		return $this->getOption('frMatchCase');
	}
	
	public function set_isMatchCase($v){
		$this->setOption('frMatchCase',$v);
	}
}
//=======================================================//
$_c->setConstList(array('csDropDown', 'csSimple', 'csDropDownList', 'csOwnerDrawFixed',
    'csOwnerDrawVariable'),0);

$_c->setConstList(array('taLeftJustify', 'taRightJustify', 'taCenter'),0);
$_c->setConstList(array('tlTop', 'tlCenter', 'tlBottom'),0);
$_c->setConstList(array('ecNormal', 'ecUpperCase', 'ecLowerCase'),0);
$_c->setConstList(array('ssNone', 'ssHorizontal', 'ssVertical', 'ssBoth'),0);
$_c->setConstList(array('bvNone', 'bvLowered', 'bvRaised', 'bvSpace'),0);

$_c->setConstList(array('doNoOrient', 'doHorizontal', 'doVertical'),0);
//$_c->setConstList(array('mrNone','mrOk','mrCancel','mrAbort','mrRetry','mrIgnore','mrYes','mrNo','mrAll','mrNoToAll','mrYesToAll'),0);

class TLabel extends TControl {
	public $class_name = __CLASS__;
}
	
	// ========================================================================== //
	class TLinkLabel extends TLabel {
    
		public $class_name_ex = __CLASS__;
		
		static function fontToArr(TFont $font){
			
			$arr['size'] = $font->size;
			$arr['color']= $font->color;
			$arr['style']= $font->style;
			$arr['name'] = $font->name;
			
			return $arr;
		}
		
		static function arrToFont(TFont $font, $arr){
			
			$font->size = $arr['size'];
			$font->color= $arr['color'];
			$font->style= $arr['style'];
			$font->name = $arr['name'];
		}
		
		function set_onMouseEnter($v){
		
		event_set($this->self, 'onMouseEnter', 'TLinkLabel::doMouseEnter');
		$this->fMouseEnter = $v;
		}
		
		function set_onMouseLeave($v){
		
		event_set($this->self, 'onMouseLeave', 'TLinkLabel::doMouseLeave');
		$this->fMouseLeave = $v;
		}
		
		//function set_onClick($v){
		//event_set($this->self, 'onClick', 'TLinkLabel::doClick');
		//$this->fClick = $v;
		//}
		
		function __initComponentInfo(){
			
			$this->fMouseEnter  = event_get($this->self,'onMouseEnter');
			event_set($this->self, 'onMouseEnter', 'TLinkLabel::doMouseEnter');
			
			$this->fMouseLeave  = event_get($this->self,'onMouseLeave');
			event_set($this->self, 'onMouseLeave', 'TLinkLabel::doMouseLeave');
			
			$this->fClick     = event_get($this->self,'onClick');
			event_set($this->self, 'onClick', 'TLinkLabel::doClick');
		}
		
		function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
			
			if ($init){
			
			if ( !$GLOBALS['APP_DESIGN_MODE'] ){ // fix
			$this->__initComponentInfo();
			}
			
				$this->fontColor  = clBlue;
				$this->hoverColor = clRed;
				$this->hoverStyle = 'fsUnderline';
				$this->hoverSize  = 0;
				$this->cursor     = crHandPoint;
			$this->autoSize   = true;
			}
		}
		
		/*/static function doClick($self){
			
			$obj = c($self);
		$link= $obj->link;
			if ( $link ){
			$x = c($link);
				
			if ($x->valid()){
			
			if (method_exists($x,'showModal'))
				$x->showModal();
			else
				$x->show();
			
			} else {
			run( $obj->link );
			}
		}
				
			if ( $obj->fClick )
				call_user_func($obj->fClick, $self);
		} /*/
		
		static function doMouseEnter($self){
			
			$obj = c($self);
		   
			
			$obj->lastFont   = self::fontToArr($obj->font);
			
			$obj->fontColor = $obj->hoverColor;
			
			if ($obj->hoverSize)
				$obj->fontSize = $obj->hoverSize;
			
			$obj->font->style = $obj->hoverStyle;
			
			if ( $obj->fMouseEnter )
				call_user_func($obj->fMouseEnter, $self);
		}
		
		static function doMouseLeave($self){
			
			$obj = c($self);
			self::arrToFont($obj->font, $obj->lastFont);
		
			if ( $obj->fMouseLeave ){
				call_user_func($obj->fMouseLeave, $self);
			}
		}
	}
	// ========================================================================== //


class TEdit extends TControl {
	public $class_name = __CLASS__;
	
	function set_passwordChar($v){
		
		$this->set_prop('passwordChar', ord($v));
	}
	
	function get_passwordChar(){
		return chr($this->get_prop('passwordChar'));
	}
	
	function get_selText(){	return edit_seltext($this->self, null); }
	function set_selText($v){ edit_seltext($this->self, (string)$v); }
	
	function get_selStart(){ return edit_selstart($this->self, null); }
	function set_selStart($v){ edit_selstart($this->self, (int)$v); }
	
	function get_selLength(){ return edit_sellength($this->self, null); }
	function set_selLength($v){ edit_sellength($this->self, (int)$v); }
	
	function selectAll(){ edit_selectall($this->self); }
	
	public function undo(){ edit_undo($this->self); }
    
	public function copyToClipboard(){ edit_copytoclipboard($this->self); }
	public function cutToClipboard(){ edit_cuttoclipboard($this->self); }
	public function pasteFromClipboard(){ edit_pastefromclipboard($this->self); }
	public function clearSelected(){ edit_clearselection($this->self); }
	public function clearSelection(){ $this->clearSelected(); }
	
}

class TMemo extends TControl {	
	public $class_name = __CLASS__;
	protected $_items;
	
	function get_items(){
		if (!isset($this->_items)){
			$this->_items = new TStrings(false);
			$this->_items->self = __rtii_link($this->self,'Lines');
		}
		return $this->_items;
	}
	
	function get_lines(){
		return $this->items;
	}
	
	function set_lines(object $strings){
		$this->items->assign($strings);
	}
	
	function set_text($v){
		$this->items->text = $v;
	}
	
	function get_text(){
		return $this->items->text;
	}
	
	function loadFromFile($fileName){
		$fileName = getFileName($fileName);
		$this->items->loadFromFile($fileName);
	}
	
	function saveToFile($fileName){
		$fileName = getFileName($fileName);
		$this->items->saveToFile($fileName);
	}
	
	function get_selText(){	return edit_seltext($this->self, null); }
	function set_selText($v){ edit_seltext($this->self, (string)$v); }
	
	function get_selStart(){ return edit_selstart($this->self, null); }
	function set_selStart($v){ edit_selstart($this->self, (int)$v); }
	
	function get_selLength(){ return edit_sellength($this->self, null); }
	function set_selLength($v){ edit_sellength($this->self, (int)$v); }
	
	function selectAll(){ edit_selectall($this->self); }
	public function undo(){ edit_undo($this->self); }
	public function redo(){ edit_redo($this->self); }
    
	public function copyToClipboard(){ edit_copytoclipboard($this->self); }
	public function cutToClipboard(){ edit_cuttoclipboard($this->self); }
	public function pasteFromClipboard(){ edit_pastefromclipboard($this->self); }
	public function clearSelected(){ edit_clearselection($this->self); }
	public function clearSelection(){ $this->clearSelected(); }
	
	
}

class TRichEdit extends TMemo {
	
	public $class_name = __CLASS__;
	
	public function loadFromFile($file){
		$file = getFileName($file);
		
		rich_loadfile($this->self, $file);
	}
	
	public function saveToFile($file){
		
		$file = replaceSr($file);
		rich_savetofile($this->self, $file);
	}
	
	public function get_RTFText(){
		return rich_text($this->self, null);
	}
	
	public function set_RTFText($v){
		rich_text($this->self, $v);
	}
	
	public function param($name, $value = null){
		
		return rich_command($this->self, (string)$name, $value);
	}
	
	
	public function set_fontName($v){ $this->param('name',$v); }
	public function get_fontName(){ return $this->param('name'); }
	
	public function set_fontSize($v){ $this->param('size',$v); }
	public function get_fontSize(){ return $this->param('size'); }
	
	public function set_fontColor($v){ $this->param('color',$v); }
	public function get_fontColor(){ return $this->param('color'); }
	
	public function set_fontCharset($v){ $this->param('charset',$v); }
	public function get_fontCharset(){ return $this->param('charset'); }
	
	public function set_bold($v){ $this->param('bold',(bool)$v); }
	public function get_bold(){ return $this->param('bold'); }
	
	public function set_italic($v){ $this->param('italic',(bool)$v); }
	public function get_italic(){ return $this->param('italic'); }
	
	public function set_strikeout($v){ $this->param('strikeout',(bool)$v); }
	public function get_strikeout(){ return $this->param('strikeout'); }
	
	public function set_underline($v){ $this->param('underline',(bool)$v); }
	public function get_underline(){ return $this->param('underline'); }
	
}

class TCheckBox extends TControl {
	public $class_name = __CLASS__;
	
	public function set_checked($v){
		$this->set_prop('checked', (bool)$v);
	}
}

class TRadioButton extends TControl {
	public $class_name = __CLASS__;
}

class TListBox extends TControl {
	public $class_name = __CLASS__;
	protected $_items;
	
        function getFont($index){
              $font = gui_listGetFont($this->self, $index);
              if ( $font )
                    return new TRealFont( $font );
              else
                    return null;
        }

        function clearFont($index){
              gui_listClearFont( $this->self, $index );
        }

        function setItemColor($index, $color){
              gui_listSetColor( $this->self, $index, $color );
        }

        function clearItemColor($index){
              $this->setItemColor($index, clNone);
        }

        function getItemColor($index){
              return gui_listGetColor( $this->self, $index );
        }

	function get_items(){
		if (!isset($this->_items)){
			$this->_items = new TStrings(false);
			$this->_items->self = __rtii_link($this->self,'Items');
			$this->_items->parent_object = $this->self;
		}
		return $this->_items;
	}
	
	function get_itemIndex(){
		return $this->items->itemIndex;
	}
	
	function set_itemIndex($v){
		$this->items->itemIndex = $v;
	}
	
	function set_inText($v){
		$this->items->setLine($this->itemIndex, $v);
	}
	
	function get_inText(){
		return $this->items->getLine($this->itemIndex);
	}
	
	function set_text($v){
		$this->items->text = $v;
	}
	
	function clear(){
		
		$this->text = '';
	}
	
	function get_text(){
		return $this->items->text;
	}
	
	function isSelected($index, $value = null){
		
		if ($index < 0)
			return false;
		else
			return listbox_selected($this->self,$index, $value);
	}
	
	// return array
	function getSelected(){
		
		$c      = $this->items->count;
		$result = array();
		
		for ($i=0;$i<$c;$i++){
			
			if ($this->isSelected($i))
				$result[] = $this->items->getLine($i);
		}
		return $result;
	}
	
	function unSelectedAll(){
		
		$c      = $this->items->count;
		$result = array();
		for ($i=0;$i<$c;$i++){			
			$this->isSelected($i, false);
		}
	}
	
	function setSelected($arr){
		
		$this->unSelectedAll();
		foreach ($arr as $el){
			
			$index = $this->items->indexOf($el);
			
			$this->isSelected($index, true);
		}
	}
}


class TComboBox extends TControl {
	public $class_name = __CLASS__;
	protected $_items;
	
	function get_items(){
		if (!isset($this->_items)){
			$this->_items = new TStrings(false);
			$this->_items->self = __rtii_link($this->self,'Items');
			$this->_items->parent_object = $this->self;
		}
		return $this->_items;
	}
	
	function get_itemIndex(){
		return $this->items->itemIndex;
	}
	
	function set_itemIndex($v){
		
		$this->items->itemIndex = $v;
	}
	
	function set_text($v){
		$this->items->text = $v;
	}
	
	function get_text(){
		return $this->items->text;
	}
	
	function set_inText($v){
		$this->set_prop('text', $v);
	}
	
	function get_inText(){
		return $this->get_prop('text');
	}
}

$_c->setConstList(array('pbHorizontal', 'pbVertical'),0);

class TProgressBar extends TControl {
	public $class_name = __CLASS__;
}

class TScrollBar extends TControl {
	public $class_name = __CLASS__;
}

class TGroupBox extends TControl {
	public $class_name = __CLASS__;
	
	function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
		
		$this->parentColor = false;
	}
}

class TRadioGroup extends TControl {
	public $class_name = __CLASS__;
	protected $_items;
	
	function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
		if ($init)
			$this->parentColor = false;
	}
	
	function get_items(){
		if (!isset($this->_items)){
			$this->_items = new TStrings(false);
			$this->_items->self = __rtii_link($this->self,'Items');
			$this->_items->parent_object = $this->self;
		}
		return $this->_items;
	}
	
	function set_text($v){
		$this->items->text = $v;
	}
	
	function get_text(){
		return $this->items->text;
	}
}

class TPanel extends TControl {
	public $class_name = __CLASS__;
	protected $_constraints;
	
	public function __construct($onwer=nil, $init=true, $self=nil){
		parent::__construct($onwer,$init,$self);
			
		if ($init)
			$this->parentColor = false;	
	}
	
	
	function get_constraints(){
		if (!isset($this->_constraints)){
			$this->_constraints = new TSizeConstraints(nil, false);
			$this->_constraints->self = gui_propGet($this->self,'constraints');
		}
		return $this->_constraints;
	}
}
//=======================================================//
class TTimer extends TControl{
	public $class_name = __CLASS__;
}

class TTimerEx extends TPanel{
	
	public $class_name_ex = __CLASS__;
	#public $time_out = true;
	public $_timer;
	#public $var_name = ''; // название переменной которая освобождается после отработки таймера
	#public $func_name = ''; // название функции которую нужно выполнить после отработки таймера
	#public $func_arguments = array(); // аргументы функции...
	#public $eval_str = '';
	
	#event onTimer 
	
	static function doTimer($self){
		
		$self = gui_owner($self);
		$props = TComponent::__getPropExArray($self);
		
		// надо сразу избавляться от продолжения таймера, иначе баг =)
		if ($props['time_out']){
			$obj = _c($self);
			$obj->timer->enabled = false;
		}
		
		if ($props['ontimer']){
				eval($props['ontimer'] . '('.$self.');');
		}
		
		if ($props['func_name']){
			
			
			if ($props['checkresult']){
				eval('$result = '.$props['func_name'] . ';');
				if ( $result===true ){
					
					$obj = _c($self);
					//$obj->timer->enabled = false;
					$obj->free();
				}
			}
			else
				eval($props['func_name'] . ';');
		}
		
		if ($props['freeonend']){
			
			$obj->free();
		}
	}
	
	public function __construct($onwer=nil, $init=true, $self=nil){
		parent::__construct($onwer,$init,$self);
		
		if ($init){
			$this->timer->enabled = false;
		}
		
		$this->__setAllPropEx();
	}
	
	function get_timer(){
		
		if (!$this->timer_self){
			$this->_timer = new TTimer($this);
			$this->_timer->name = 'timer';
			$this->_timer->onTimer = 'TTimerEx::doTimer';
			$this->timer_self = $this->_timer->self;
		} else {
			$this->_timer = c($this->timer_self);
		}
		
		return $this->_timer;
	}
	
	public function set_enable($v){
		$this->timer->enabled = $v;
	}
	
	public function get_enable(){
		return $this->timer->enabled;
	}
	
	public function set_enabled($v){
		$this->enable = $v;
	}
	
	public function get_enabled(){
		return $this->enable;
	}
	
	public function set_interval($v){
		$this->timer->interval = $v;
	}
	
	public function get_interval(){
		return $this->timer->interval;
	}
	
	public function get_repeat(){
		return !$this->time_out;
	}
	
	public function set_repeat($v){
		$this->time_out = !$v;
	}
	
	public function start(){
		$this->enabled = true;
		
	}
	
	public function stop(){
		$this->enabled = false;
	}
	
	public function pause(){
		$this->enabled = !$this->enabled;
	}
	
	public function go(){$this->start();}
}


// аналог функции setTimeout из Javascript
// тайминг выполняется единожды...
function setTimeout($interval,$func){
	
	$timer = new TTimerEx();
	$timer->interval  = $interval;
	$timer->func_name = $func;
	$timer->time_out  = true;
	$timer->freeOnEnd = true;
	$timer->enable = true;
	return $timer;
}

// аналог функции setTimer
function setTimer($interval,$func){
	
	$timer = new TTimerEx();
	$timer->interval  = $interval;
	$timer->func_name = $func;
	$timer->time_out  = false;
	$timer->background = $background;
	$timer->enable = true;
	//pre($func);
	return $timer;
}

function setTimerEx($interval,$func){
	$tim = setTimer($interval, $func);
	$tim->checkResult = true;
	return $tim;
}

function setInterval($interval, $func, $background = false){
	return setTimer($interval, $func, $background);
}

function setBackTimeout($interval, $func){
	return setTimeout($interval, $func, true);
}

function setBackTimer($interval, $func){
	return setTimeout($interval, $func, true);
}

class Timer {
	
	static $exec = array();
	static $data = array();
	static $free = array();
	
	static function createTimer(){
		
		$result = 0;
		foreach(Timer::$free as $timer => $busy){
			if ( !$busy ){
				$result = $timer;
				break;
			}
		}
		
		if ( !$result )
			$result = gui_create('TTimer', null);
		
		Timer::$free[ $result ] = true;
		return $result;
	}
	
	static function setInterval($func, $interval){
		
		$result = Timer::createTimer();
		Timer::setIntervalTime($result, $interval);
		
		$myfunc = function($self) use ($func){
			Timer::$exec[ $self ] = true;
			
			call_user_func($func, $self);
			
			Timer::$exec[ $self ] = false;
		};
		
		event_set( $result, 'OnTimer', $myfunc );
		
		return $result;
	}
	
	static function setTimeout($func, $interval){
		
		$result = Timer::createTimer();
		Timer::setIntervalTime($result, $interval);
		
		$myfunc = function($self) use ($func){
			Timer::$exec[ $self ] = true;
			
			call_user_func($func, $self);
			
			Timer::removeData( $self );
			gui_propSet( $self, 'enabled', false );
			//gui_safeDestroy( $self );
			
			Timer::$exec[ $self ] = false;
		};
		event_set( $result, 'OnTimer', $myfunc );
		
		return $result;
	}
	
	static function clearTimer($timer){
		
		if ( gui_is($timer, 'TTimer') ){
			Timer::removeData( $timer );
			Timer::setEnabled( $timer, false );
			
			event_set( $result, 'OnTimer', null );
			self::$free[ $timer ] = true;
		}
	}
	
	static function clearInterval($timer){
		self::clearInterval($timer);
	}
	
	static function clearTimeout($timer){
		self::clearInterval($timer);
	}
	
	static function setIntervalTime($timer, $interval){
		gui_propSet($timer, 'interval', (int)$interval );
	}
	
	static function setEnabled($timer, $value){
		gui_propSet($timer, 'enabled', $value);
	}
	
	static function getEnabled($timer){
		return gui_propGet($timer, 'enabled');
	}
	
	static function setData($timer, $name, $value){
		if ( gui_is($timer, 'TTimer') ){
			self::$data[ $timer ][ $name ] = $value;
		}
	}
	
	static function getData($timer, $name){
		if ( gui_is($timer, 'TTimer') ){
			return self::$data[ $timer ][ $name ];
		} else
			return NULL;
	}
	
	static function removeData($timer){
		unset( self::$data[ $timer ] );
	}
}
//=======================================================//
$_c->setConstList(array('tpIdle', 'tpLowest', 'tpLower', 'tpNormal', 'tpHigher', 'tpHighest',
    'tpTimeCritical'),0);


function safe($code, $func){
    
    $p = TThread::$_criticals[ $code ];
    if ( $p ){
        gui_criticalEnter($p);
        call_user_func($func);
        gui_criticalLeave($p);
    }
}

function sync($function_name){
    
    //pre($function_name);
    if ( $GLOBALS['THREAD_SELF'] ){
        
        //$th = TThread::get($GLOBALS['THREAD_SELF']);
        
        if ( func_num_args() == 1 ){
            gui_threadSync($GLOBALS['THREAD_SELF'], 'TThread::__syncFull', igbinary_serialize(array('___callback'=>$function_name)));
        } else {
            
            $args = func_get_arg(1);
            if ( is_array($args) ){
                $args['___callback'] = $function_name;
                gui_threadSync($GLOBALS['THREAD_SELF'], 'TThread::__syncFull', igbinary_serialize($args)); 
            } else {
                trigger_error('sync() expects parameter 2 to be a array', E_USER_ERROR);
            }
        }
        
        return true;
    } else
        return false;
}

function syncEx($function_name, $args){
    
    if ( $GLOBALS['THREAD_SELF'] ){
       
        $args['___callback'] = $function_name;
        gui_threadSync($GLOBALS['THREAD_SELF'], 'TThread::__syncFull', igbinary_serialize($args));
        
        return igbinary_unserialize(gui_threadData($GLOBALS['THREAD_SELF'], 'result'));
        
        //return $th->syncFull($function_name, $args);
    } else
        return call_user_func_array($function_name, $args);
}

function critical($code){
    
    if (!TThread::$_criticals[ $code ]){
        TThread::$_criticals[ $code ] = gui_criticalCreate();
    }
}


function thread_inPool($func, $callback = null){
    
    if ( thread_count() < thread_max() ){
        if ( $callback )
            $callback(new TThread($func));
        else {
            $th = new TThread($func);
            $th->resume();
        }
    } else {
        TThread::$pool[] = array($func, $callback);    
    }
}

class TThread {
    
    //static $_criticals;
    public $self;
    static $pool;
     
    static function get($self){
        
        return new TThread(false, $self);
    }
    
    static function checkPool(){
        
        if ( sizeof(self::$pool) < 1 ) return;
        
        $can = thread_max() - thread_count() - 2;
        reset(self::$pool);        
        
        for($i=0;$i<$can;$i++){
            
            $item = current(self::$pool);
            
            $th = new TThread($item[0]);
            $callback = $item[1];
            if ( $callback )
                $callback($th);
            else
                $th->resume();
            
            self::$pool[ key(self::$pool) ] = null;
            next(self::$pool);
        }
        
        foreach(self::$pool as $key=>$item){
            if ($item == null)
                unset(self::$pool[$key]);
            else
                break;
        }
    }
    
    public function __construct($func_name = false, $self = false){
        
        if (!$self){
            $this->self = gui_threadCreate();
        }
        else
            $this->self = (int)$self;
        
        if ( $func_name )
            $this->set_onExecute($func_name);
    }
    
    public function set_onExecute($func){
        
        if ( $this->self && is_callable($func) && is_string($func) )
            event_set($this->self, 'onExecute', $func);
    }
    
    public function set_importClasses($val){
        gui_propSet($this->self, 'importClasses', (bool)$val);
    }
    
    public function set_importGlobals($val){
        gui_propSet($this->self, 'importGlobals', (bool)$val);
    }
    
    public function set_importConstants($val){
        gui_propSet($this->self, 'importConstants', (bool)$val);
    }
    
    public function get_importClasses($val){
        return gui_propGet($this->self, 'importClasses');
    }
    /*
    public function get_importGlobals($val){
        return gui_propGet($this->self, 'importGlobals');
    }*/
    
    public function get_importConstants($val){
        return gui_propGet($this->self, 'importConstants');
    }
    
    public function get_priority(){
        return gui_threadPriority($this->self);
    }
    
    public function set_priority($v){
        return gui_threadPriority($this->self, $v);
    }
    
    public function resume(){
        if ( $this->self )
            return gui_threadResume($this->self);
    }
    
    public function suspend(){
        if ( $this->self )
            return gui_threadSuspend($this->self);
    }
    
    public function terminate(){
        
        if ( $this->self ){
            gui_threadTerminate($this->self);
            $this->self = false;
        }
    }
    
    public function sync($func, $addData = ''){
        
        if ( $this->self && is_string($func) )
            gui_threadSync($this->self, $func, $addData);
    }
    
    static function __syncFull($self, $addData){
        
        $th = TThread::get($self);
        $args = igbinary_unserialize($addData);
        $callback = $args['___callback'];
        unset($args['___callback']);
        $th->result = call_user_func_array( $callback, $args );
    }
    
    public function syncFull($func, $args){
        
        if ( $this->self && is_string($func) ){
            
            //$this->callback = $func;
            $args = array_values($args);
            $args['___callback'] = $func;
            
            $this->sync('TThread::__syncFull', igbinary_serialize($args));
            return $this->result;
        }
    }
    
    public function synchronize($func){
        $this->sync($func);
    }
    
    public function free(){
        
        gui_threadFree($this->self);
        $this->self = false;
    }
    
    public function __get($name){
        
        if ( method_exists($this, 'get_' . $name) )
            return call_user_func(array($this, 'get_'.$name));
            
        $result = igbinary_unserialize(gui_threadData($this->self, $name));
	return $result;
    }
    
    public function __set($name, $value){

        if ( method_exists($this, 'set_' . $name) )
            return call_user_func(array($this, 'set_'.$name), $value);
        
        gui_threadData($this->self, $name, igbinary_serialize($value));
    }
    
    public function __isset($name){
        
        return gui_threadDataIsset($this->self, $name);
    }
    
    public function __unset($name){
        
        gui_threadDataUnset($this->self, $name);
    }
    
    // call when run thread
    static function __init(){
        errors_init();
        if ( class_exists('DS_Loader') )
              DS_Loader::InitLoader(true);
    }
}

Timer::setInterval('TThread::checkPool', 1000);


function v($name, $value = null){
    
    return enc_v($name, $value);
}

function enc_v($name, $value = null){
    
    if ($value === null)
        return enc_getValue( $name );
    else
        enc_setValue( $name, urlencode(serialize($value)) );
}

function define_ex($name, $value){
    
    define($name, $value, false);
}
//=======================================================//
$_c->setConstList(array('blGlyphLeft', 'blGlyphRight', 'blGlyphTop', 'blGlyphBottom'),0);

class TButton extends TControl {
	public $class_name = __CLASS__;
}

class TBitBtn extends TControl {
	public $class_name = __CLASS__;
	protected $_picture;
	
	public function get_picture(){
		
		if (!isset($this->_picture)){
			$this->_picture = new TBitmap(false);
			$this->_picture->self = gui_propGet($this->self,'Glyph');
			$this->_picture->parent_object = $this->self;
		}
		
		return $this->_picture;
	}
	
	public function doClick(){
		
		eval(get_event($this->self, 'onClick').'('.$this->self.');');
	}
	
	public function loadPicture($file){
		$this->picture->loadAnyFile($file);
	}
	
	public function loadFromBitmap($bt){
		$this->picture->assign($bt);
	}
}

class TSpeedButton extends TBitBtn {
	public $class_name = __CLASS__;
}

class TPNGGlyph {
	
	public $self;
	
	public function __construct($self){
		$this->self = $self;	
	}
	
	public function assign($pic){
		
		if ( !gui_btnPNGAssign($this->self, $pic->self) ){
			_c($this->self)->picture->assign($pic);
		}
	}
	
	public function loadFromFile($file){
		
		if ( fileExt($file) == 'png' )
			_c($this->self)->loadPNGFile($file);
		else
			_c($this->self)->picture->loadFromFile($file);
	}
	
	public function loadAnyFile($filename){
		$this->loadFromFile($filename);
    }
	
	public function loadPNGStr($str){
		_c($this->self)->loadPNGFile($str);
	}
	
	public function isEmpty(){
		return gui_btnPngIsEmpty($this->self) && _c($this->self)->picture->isEmpty();
	}
}

class TPNGSpeedButton extends TBitBtn {
	
	public $class_name = __CLASS__;
	protected $_pngpicture;
	
	function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
		
		if ($init){
			$this->Spacing = 12;
		}
	}
	
	public function get_pngpicture(){
		
		if (!isset($this->_pngpicture))
			$this->_pngpicture = new TPNGGlyph($this->self);
		
		return $this->_pngpicture;
	}
	
	public function loadPNGStr( $data ){
		gui_btnPNGLoadStr($this->self, $data);
	}
	
	public function loadPNGFile( $file ){
		gui_btnPNGLoadFile($this->self, $file);
	}
	
	public function getPNGStr(){
		return gui_btnPNGGetStr($this->self);
	}
}

class TPNGBitBtn extends TPNGSpeedButton {
	
	public $class_name = __CLASS__;

}
//=======================================================//
//TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom);
$_c->setConstList(array('alNone', 'alTop', 'alBottom', 'alLeft', 'alRight', 'alClient', 'alCustom'),0);
$_c->setConstList(array('tsTabs', 'tsButtons', 'tsFlatButtons'),0);
$_c->setConstList(array('lbStandard', 'lbOwnerDrawFixed', 'lbOwnerDrawVariable',
    'lbVirtual', 'lbVirtualOwnerDraw'),0);
$_c->setConstList(array('cbUnchecked', 'cbChecked', 'cbGrayed'),0);

$_c->setConstList(array('trHorizontal', 'trVertical'), 0);
$_c->setConstList(array('tmBottomRight', 'tmTopLeft', 'tmBoth'), 0);
$_c->setConstList(array('tsNone', 'tsAuto', 'tsManual'), 0);

$_c->setConstList(array('sbHorizontal', 'sbVertical'), 0);
$_c->setConstList(array('scLineUp', 'scLineDown', 'scPageUp', 'scPageDown', 'scPosition',
    'scTrack', 'scTop', 'scBottom', 'scEndScroll'),0);

$_c->setConstList(array('dfShort','dfLong'), 0);
$_c->setConstList(array('dmComboBox','dmUpDown'), 0);
$_c->setConstList(array('dtkDate','dtkTime'), 0);

$_c->setConstList(array('bsBox', 'bsFrame', 'bsTopLine', 'bsBottomLine', 'bsLeftLine',
                                'bsRightLine', 'bsSpacer'),0);

class TCoolTrayIcon extends TControl {
	public $class_name = __CLASS__;
	protected $_picture;
	protected $_icon;
	
	public function get_picture(){
		
		if (!isset($this->_picture)){
			$this->_picture = new TIcon(false);
			$this->_picture->self = __rtii_link($this->self,'Icon');
			$this->_picture->parent_object = $this->self;
		}
		
		return $this->_picture;
	}
	
	public function get_icon(){
		return $this->picture;
	}
	
	public function loadPicture($file){
		
		$this->picture->loadAnyFile($file);
	}
	
	public function loadFromBitmap($bt){
		
		$this->picture->assign($bt);
	}
	
	public function set_iconFile($v){
		
		$this->aiconFile = $v;
		$v = getFileName($v);
		if (!file_exists($v)) return;
		
		$this->loadPicture($v);
	}
	
	public function get_iconFile(){
		return $this->aiconFile;
	}
	
	public function get_hint(){
		return $this->get_prop('hint');
	}
	
	public function set_hint($v){
		$this->set_prop('hint',$v);
	}
	
	public function assign($icon){
		trayicon_assign($this->self, $icon->self);
	}
	
	public function showBalloonTip(){
		
		return trayicon_balloontip($this->self, $this->title, $this->text, $this->flag, $this->timeout);
	}
	
	public function hideBalloonTip(){
		return trayicon_hideballoontip($this->self);
	}
}

class TTrackBar extends TControl {
	public $class_name = __CLASS__;
}


class THotKey extends TControl {
	public $class_name = __CLASS__;
	
	public function set_hotKey($sc){
		
		if (!is_numeric($sc))
			$sc = text_to_shortcut(strtoupper($sc));
		$this->set_prop('hotKey',$sc);
	}
	
	public function get_hotKey(){
		
		$result = $this->get_prop('hotKey');
		return shortCut_to_text($result);
	}
}



class TMaskEdit extends TControl {
	public $class_name = __CLASS__;
}


class TImage extends TControl {
	public $class_name = __CLASS__;
	protected $_picture;
	
	public function get_picture(){
		
		if (!isset($this->_picture)){
			$this->_picture = new TPicture(false);
			$this->_picture->self = __rtii_link($this->self,'Picture');
			$this->_picture->parent_object = $this->self;
		}
		
		return $this->_picture;
	}
	
	public function getCanvas(){
		
		$tmp = new TCanvas(false);
		$tmp->self = component_canvas($this->self);
		
		return $tmp;
	}
	
	public function loadPicture($file){
		
		$this->picture->loadAnyFile($file);
	}
	
	public function loadFromFile($file){
		$this->loadPicture($file);
	}
	
	public function loadFromBitmap($bt){
		
		$this->picture->assign($bt);
	}
	
	public function loadFromUrl($url, $ext = false){
		$this->picture->loadFromUrl($url, $ext = false);
	}
	
	public function saveToFile($file){
		$file = replaceSl($file);
		$this->picture->saveToFile($file);
	}
}

class TMImage extends TImage {
    
    public $class_name = __CLASS__;
}

class TDrawGrid extends TControl {
	public $class_name = __CLASS__;
}

class TShape extends TControl {
	public $class_name = __CLASS__;
	
	protected $_brush;
	protected $_pen;

	
	public function get_brush(){
		
		if (!$this->_brush){
			$this->_brush = new TBrush(false);
			$this->_brush->self = __rtii_link($this->self,'Brush');
		}
		return $this->_brush;
	}
	
	public function get_pen(){
		
		if (!$this->_pen){
			
			$this->_pen   = new TPen(false);
			$this->_pen->self   = __rtii_link($this->self,'Pen');
		}
		
		return $this->_pen;
	}
	
	function get_brushColor(){ return $this->brush->color; }
	function set_brushColor($v){ $this->brush->color = $v; }
	function get_brushStyle(){ return $this->brush->style; }
	function set_brushStyle($v){ $this->brush->style = $v; }
	
	function get_penColor(){ return $this->pen->color; }
	function set_penColor($v){ $this->pen->color = $v; }
	function get_penMode(){ return $this->pen->mode; }
	function set_penMode($v){ $this->pen->mode = $v; }
	function get_penStyle(){ return $this->pen->style; }
	function set_penStyle($v){ $this->pen->style = $v; }
	function get_penWidth(){ return $this->pen->width; }
	function set_penWidth($v){ $this->pen->width = $v; }
}

class TBevel extends TControl {
	public $class_name = __CLASS__;
}

class TScrollBox extends TControl {
	public $class_name = __CLASS__;
	protected $_constraints;	
	
	function get_constraints(){
		if (!isset($this->_constraints)){
			$this->_constraints = new TSizeConstraints(nil, false);
			$this->_constraints->self = __rtii_link($this->self,'constraints');
		}
		return $this->_constraints;
	}
	
	public function isVScrollShowing(){
		
		return scrollbox_vsshowing($this->self);
	}
	
	public function isHScrollShowing(){
		
		return scrollbox_hsshowing($this->self);
	}
	
	public function get_scrollBarSize(){
		return scrollbox_sbsize($this->self);
	}
}

class TCheckListBox extends TControl {
	public $class_name = __CLASS__;
	protected $_items;
	
	function get_items(){
		if (!isset($this->_items)){
			$this->_items = new TStrings(false);
			$this->_items->self = __rtii_link($this->self,'Items');
			$this->_items->parent_object = $this->self;
		}
		return $this->_items;
	}
	
	function isChecked($index){
		
		return checklist_checked($this->self, $index);
	}
	
	function setChecked($index, $value = true){
		checklist_setchecked($this->self, $index, $value);
	}
	
	function get_checkedItems(){
		$result = array();
		$list = $this->items->lines;
		if (count($list))
		foreach ($list as $index=>$v){
			if ($this->isChecked($index))
				$result[$index] = $v;
		}
		
		return $result;
	}
	
	function set_checkedItems($v){
		
		$list = $this->items->lines;
		
		if (count($list))
		foreach ($list as $index=>$x){
			
			$this->setChecked($index, in_array($x, $v));
		}
	}
	
	function unCheckedAll(){
		$this->checkedItems = array();
	}
	
	function checkedAll(){
		$list = $this->items->lines;
		$this->checkedItems = $list;
	}
	
	function get_itemIndex(){
		return $this->items->itemIndex;
	}
	
	function set_itemIndex($v){
		$this->items->itemIndex = $v;
	}
	
	function set_inText($v){
		$this->items->setLine($this->itemIndex, $v);
	}
	
	function get_inText(){
		return $this->items->getLine($this->itemIndex);
	}
	
	function set_text($v){
		$this->items->text = $v;
	}
	
	function clear(){
		
		$this->text = '';
	}
	
	function get_text(){
		return $this->items->text;
	}
}

class TSplitter extends TControl {
	public $class_name = __CLASS__;
}

class TStaticText extends TControl {
	public $class_name = __CLASS__;
}

class TControlBar extends TControl {
	public $class_name = __CLASS__;
}

class TValueListEditor extends TControl {
	public $class_name = __CLASS__;
}

class TLabeledEdit extends TControl {
	public $class_name = __CLASS__;
}

class TColorBox extends TControl {
	public $class_name = __CLASS__;
}

class TStatusBar extends TControl {
	public $class_name = __CLASS__;
	
	function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
		
		if ($init){
			$this->useSystemFont = false;
			$this->simplePanel   = true;
		}
	}
}

class TColorListBox extends TControl {
	public $class_name = __CLASS__;
}


class TTabSet extends TControl {
	public $class_name = __CLASS__;
}


class TTabControl extends TControl {
	public $class_name = __CLASS__;
	protected $_tabs;
	
	function get_tabs(){
		if (!isset($this->_tabs)){
			$this->_tabs = new TStrings(false);
			$this->_tabs->self = gui_propGet($this->self,'tabs');
			$this->_tabs->parent_object = $this->self;
		}
		return $this->_tabs;
	}
	
	function addPage($caption){
		
		$tabs = $this->tabs;
		$tabs->add($caption);
	}
	
	
	function indexOfTabXY($x, $y){
		
		return tabcontrol_indexofxy($this->self, $x, $y);
	}
	
	function set_text($v){
		$this->tabs->text = $v;
	}
	
	function get_text(){
		return $this->tabs->text;
	}
}

class TPageControl extends TControl {
	public $class_name = __CLASS__;
	public $pages;
	
	function __loadDesign(){
		
		$this->__initComponentInfo();
	}
	
	function __initComponentInfo(){
		
		$index = (int)$this->apageIndex;
		if ($index == 0){
			if ($this->pageCount == 1){
				$this->addPage('-');
				$this->pageIndex = 1;
				$this->pageIndex = $index;
				$this->delete(1);
			} else {
				$this->pageIndex = 1;
				$this->pageIndex = $index;
			}
		} else {
			$this->pageIndex = $index;
		}
	}
	
	function set_ActivePage($page){
		
		pagecontrol_activepage($this->self, $page->self);
		$this->apageIndex = $this->pageIndex;
	}
	
	function get_ActivePage(){
		
		return _c(pagecontrol_activepage($this->self, null));
	}
	
	function addPage($caption){
		
		$p = new TTabSheet(_c($this->owner));
		$p->parent = $this;
		$p->parentControl = $this;
		$p->caption = $caption;
		$p->doubleBuffer = true;
		$p->aenabled = true;
		$p->avisible = true;
		
		return $p;
	}
	
	function get_pageCount(){
		
		return pagecontrol_pagecount($this->self);
	}
	
	function pages(){
		
		$c = $this->pageCount;
		
		for ($i=0; $i<$c; $i++){
			
			$result[] = _c(pagecontrol_pages($this->self,$i));
		}
		
		return $result;
	}
	
	function set_pageIndex($v){
		$pages = $this->pages();
		
		if ($pages[$v]){
			//c('fmMain')->caption = ($pages[$v]->caption);
			$this->ActivePage = $pages[$v];
			$pages[$v]->visible = true;
		}
	}
	
	function get_pageIndex(){
		
		$a_page = $this->ActivePage;
		$pages  = $this->pages();
		
		for ($i=0; $i<count($pages); $i++){
			if ($pages[$i]->self == $a_page->self)
				return $i;
		}
		return -1;
	}
	
	function set_pagesList($arr){
		
		if (!is_array($arr))
			$arr = explode(_BR_, $arr);
		
		foreach ($arr as $i=>$el){
			if ($el)
			$tmp[] = trim($el);
		}
		
		unset($arr);
		$arr =& $tmp;
		
		$pages = $this->pages();
		for ($i=0; $i<count($pages); $i++){
			
			if (count($arr)-1<$i){
				$pages[$i]->free();
			} else {
				$pages[$i]->caption = $arr[$i];
			}
		}
		
		for ($i=count($pages)-1; $i<count($arr)-1; $i++)
			$this->addPage($arr[$i+1]);
		
	}
	
	function get_pagesList(){
		
		$pages = $this->pages();
		$result = array();
		
		
		for($i=0; $i<count($pages); $i++){
			$result[] = $pages[$i]->caption;
		}
		
		return implode(_BR_, $result);
	}
	
	function clear(){
		$pages = $this->pages();
		for ($i=0; $i<count($pages); $i++)
			$pages[$i]->free();
	}
	
	function delete($index){
		$pages = $this->pages();
		
		if ($pages[$index])
			$pages[$index]->free();
	}
	
}

class TTabSheet extends TControl {
	public $class_name = __CLASS__;
	
	function set_parentControl($obj){
		tabsheet_parent($this->self, $obj->self);
	}
	
	function get_parentControl(){
		return _c(tabsheet_parent($this->self,0));
	}
	
	function free(){
		
		foreach ($this->componentList as $el)
			$el->free();
			
		parent::free();
	}
}


class TSizeConstraints extends TComponent {
	
	public $class_name = __CLASS__;
	
	#maxWidth
	#maxHeight
	#minWidth
	#minHeight

}

class TPadding extends TControl {
	
	public $class_name = __CLASS__;
}

class TListItems extends TControl {
	
	public $class_name = __CLASS__;
	
	function delete($index){ listitems_command($this->self, __FUNCTION__, $index,0); }
	function add(){ return _c(listitems_command($this->self, __FUNCTION__,0,0)); }
	function clear(){ listitems_command($this->self, __FUNCTION__,0,0); }
	function addItem($item, $index) { return _c(listitems_command($this->self, __FUNCTION__, $item->self, $index)); }
	function indexOf($item) { return listitems_command($this->self, __FUNCTION__, $item->self, 0); }
	function insert($index) { return _c(listitems_command($this->self, __FUNCTION__, $index, 0)); }
	
	function count(){ return listitems_command($this->self, __FUNCTION__, 0, 0); }
	function get($index){ return _c(listitems_command($this->self, __FUNCTION__, $index, 0)); }
	
	function get_selected(){
		
		$result = array();
		$arr = explode(',',listitems_command($this->self, 'selected', 0,0));
		
		foreach ($arr as $el) if ($el!='')
			$result[] = $el;
		
		return $result;
	}
	
	function set_selected($var){
			
		foreach ($var as $k=>$v)
			listitems_selected($this->self, $k, $v);
	}
	
	function select($index){
		listitems_selected($this->self, $index, true);
	}
	
	function unSelect($index){
		listitems_selected($this->self, $index, false);
	}
	
	function unSelectAll(){
		$c = $this->count();
		for($i=0; $i<$c-1; $i++)
			$this->unSelect($i);
	}
	
	function selectAll(){
		$c = $this->count();
		for($i=0; $i<$c-1; $i++)
			$this->select($i);
	}
	
	function indexByCaption($caption){
		
		$c       = $this->count();
		$caption = strtolower($caption);
		
		for ($i=0; $i<$c; $i++){
			
			$item = $this->get($i);
			if (strtolower($item->caption)==$caption)
				return $i;
		}
		
		return -1;
	}
	
	function selectByCaption($caption){
		
		if (is_array($caption)){
			$this->unSelectAll();
			if (count($caption)){
			foreach ($caption as $el){
				$index = $this->indexByCaption($el);
				if ($index > -1)
					$this->select($index);
			}
			}
		} else {
			$index = $this->indexByCaption($caption);
			$this->unSelectAll();
			if ($index > -1)
				$this->select($index);
		}
	}
	
	function get_selectedCaption(){
		
		$arr    = $this->selected;
		$result = array();
		foreach ($arr as $id){
			
			$result[] = $this->get($id)->caption;
		}
		return $result;
	}
	
	function set_selectedCaption($caption){
		$this->selectByCaption($caption);
	}
}

class TListItem extends TControl {
	
	public $class_name = __CLASS__;
	
	function delete(){ listitem_command($this->self, __FUNCTION__); }
	function update(){ listitem_command($this->self, __FUNCTION__); }
	function canceledit(){ listitem_command($this->self, __FUNCTION__); }
	function editcaption(){ return listitem_command($this->self, __FUNCTION__); }
	
	function get_index(){ return listitem_prop($this->self, __FUNCTION__, null);}
	function get_selected() { return listitem_prop($this->self, __FUNCTION__, null);}
	
	function get_imageindex() {return listitem_prop($this->self, __FUNCTION__, null);}
	function get_stateindex() {return listitem_prop($this->self, __FUNCTION__, null);}
	function get_indent() {return listitem_prop($this->self, __FUNCTION__, null);}
	function get_caption() {return listitem_prop($this->self, __FUNCTION__, null);}
	function get_checked() {return listitem_prop($this->self, __FUNCTION__, null);}
	
	function set_imageindex($v) {listitem_prop($this->self, __FUNCTION__, $v);}
	function set_stateindex($v) {listitem_prop($this->self, __FUNCTION__, $v);}
	function set_indent($v) {listitem_prop($this->self, __FUNCTION__, $v);}
	function set_caption($v) {listitem_prop($this->self, __FUNCTION__, $v);}
	function set_checked($v) {listitem_prop($this->self, __FUNCTION__, $v);}
	
	function set_subItems($arr){
		
		if (is_array($arr))
			$arr = implode(_BR_, $arr);
		
		listitem_prop($this->self, __FUNCTION__, $arr);
	}
	
	function get_subItems(){
		$str = listitem_prop($this->self, __FUNCTION__, null);
		return explode(_BR_, $str);
	}
}

class TListView extends TControl {
	
	public $class_name = __CLASS__;
	protected $_items;
	
	function get_items(){
		
		if (!$this->_items){
			$this->_items = new TListItems($this,false);
			$this->_items->self = __rtii_link($this->self,'items');
		}
		return $this->_items;
	}
	
	function set_images($c){
		imagelist_set_images($this->self, $c->self);
	}
	
	function get_selected(){
		return $this->items->get_selected();
	}
}


class TDateTimePicker extends TControl {
	
	public $class_name = __CLASS__;
	
	public function get_date(){
		
		return datetime_str($this->get_prop('date'));
	}
	
	function set_date($v){ $this->set_prop('date', str_datetime($v)); }
	
	function get_maxDate(){ return datetime_str($this->get_prop('maxDate'));}
	function get_minDate(){ return datetime_str($this->get_prop('minDate'));}
	function get_time(){return wtime_str($this->get_prop('time'));}
	
	function set_maxDate($v){ $this->set_prop('maxDate', str_datetime($v)); }
	function set_minDate($v){ $this->set_prop('minDate', str_datetime($v)); }
	function set_time($v){ $this->set_prop('time', str_wtime($v)); }
	
}

class TTreeView extends TControl {
	
	public $class_name = __CLASS__;
	
	public function loadFromStr($str){
		
		tree_loadstr($this->self,$str);
	}
	
	public function get_text(){
		
		return tree_gettext($this->self);
	}
	
	public function set_text($v){
		$this->loadFromStr($v);
	}
	
	public function get_itemSelected(){
		
		$arr = explode(_BR_,$this->text);
		return trim($arr[ $this->absIndex ]);
	}
	
	public function set_itemSelected($v){
		
		$this->absIndex = -1;
		$v   = strtolower($v);
		$arr = explode(_BR_,$this->text);
		foreach ($arr as $i=>$text){
			$text = strtolower(trim($text));
			if ($v==$text){
				$this->absIndex = $i;
			}
		}
	}
	
	public function get_selected(){
		
		$res = tree_selected($this->self);
		if ($res === null){
			return null;
		} else
			return _c( $res );
	}
	
	public function set_selected($v){
		
		tree_select($this->self, $v->self);
	}
	
	public function get_absIndex(){
		$sel = $this->selected;
		if ($sel)
			return $sel->absIndex;
		else
			return -1;
	}
	
	public function set_absIndex($v){
		return tree_setAbsIndex($this->self, (int)$v);
	}
	
	public function fullExpand(){
		tree_fullExpand($this->self);
	}
	
	public function fullCollapse(){
		tree_fullCollapse($this->self);
	}
}

class TTreeNode extends TControl {
	
	public $class_name = __CLASS__;
	
	public function get_absIndex(){
		return tree_absIndex($this->self);
	}
}
//=======================================================//
class styleMenu {
	
	// add to style menu main or popup
	static function add($menu){
		stylemenu_command($menu->self, 'add', null);
	}
	
	static function addItem($item){
		stylemenu_command($item->self, 'additem', null);
	}
	
	static function param($name,$value = false){
		if ($value)
			stylemenu_command(0, $name, $color);
		else
			return stylemenu_command(0, $name, null);
	}
	
	static function selectedColor($color = false){ return self::param('selectedcolor',$color); }
	static function menuColor($color = false){ return self::param('menucolor',$color); }
	static function gutterColor($color = false) { return self::param('guttercolor', $color); }
	static function minHeight($v = false){ return self::param('minheight',$v); }
	static function minWidth($v = false) { return self::param('minwidth', $v); }
}


function menuDinamicSetText($menu, $text){
	
	$arr = explode($text);
	
	foreach ($arr as $el){
		
		$item = explode('|', $el);
		$caption = $item[0];
		$x = new TMenuItem($menu);
		$x->caption = $caption;
		if ($item[1]){
			$x->loadPicture($item[1]);
		}
		if ($item[2]){
			$x->onClick = $item[2];
		}
		$menu->addItem($x);
	}
}

class TMainMenu extends TControl {
	public $class_name = __CLASS__;	
	
	function set_images(TImageList $il){
		//rtii_set($this, 'Images', $il->self);
	}
	
	function get_images(){
		
		//return _c(rtii_get($this, 'Images'));
	}
	
	function get_items(){
		
		return _c( rtii_get($this, 'Items') );
	}
	
	function addItem(TMenuItem $item, $parent_item = false){
		
		if ($parent_item)
			$parent_item->addItem($item);
		else
			mainmenu_additem($this->self, $item->self);
	}
}

function menuItem($caption, $styled = false, $name = '', $onClick = '', $sc = false, $img = false){
	
	$result = new TMenuItem;
	if ($name)
		$result->name = $name;
	
	if ($onClick)
		$result->onClick = $onClick;
	
	$result->caption = $caption;
	if ($sc)
		$result->shortCut = $sc;
	if ($img){
		
		if (file_exists( replaceSl($img) ))
			$result->picture->loadFromFile( replaceSr($img) );
		else
			if (file_exists( replaceSl(DOC_ROOT.'/'.$img) ))	
			$result->picture->loadFromFile( replaceSr(DOC_ROOT.'/'.$img) );
	}
		
	if ($styled)
		styleMenu::addItem($result);
		
	return $result;
}

class TMenuItem extends TControl {
	public $class_name = __CLASS__;
	public $picture;
	
	public function __construct($onwer=nil, $init=true, $self=nil){
		parent::__construct($onwer,$init,$self);
		$this->picture = new TBitmap(false);
		$this->picture->self = __rtii_link($this->self,'Bitmap');
		
		$this->picture->parent_object = $this->self;
	}
	
	public function loadPicture($file){
		
		$this->picture->loadAnyFile($file);
	}
	
	
	function set_visible($v){
		$this->set_prop('visible', (bool)$v);
	}
	
	function get_visible(){
		
		return $this->get_prop('visible');
	}
	
	function set_enabled($v){
		$this->set_prop('enabled', (bool)$v);
	}
	
	function get_enabled(){
		
		return $this->get_prop('enabled');
	}
	
	public function set_shortCut($sc){
		
		if (!is_numeric($sc))
			$sc = text_to_shortcut(strtoupper($sc));
		$this->set_prop('shortCut',$sc);
	}
	
	public function get_shortCut(){
		
		$result = $this->get_prop('shortCut');
		return shortCut_to_text($result);
	}
	
	public function addItem(TMenuItem $item){
		
		popup_additemex($this->self, $item->self);
	}
	
	public function clear(){
		menuitem_clear($this->self);
	}
	
	public function delete($index){
		menuitem_delete($this->self, $index);
	}
	
	public function insert($index, TMenuItem $item){
		menu_insert($this->self, (int)$index, $item->self);
	}
	
	public function insertAfter(TMenuItem $after, TMenuItem $item){
		
		$index = $this->indexOf($after);
		
		if ($index >= 0){
			$this->insert($index+1, $item);
		}
	}
	
	public function insertBefore(TMenuItem $after, TMenuItem $item){
		
		$index = $this->indexOf($after);
		
		if ($index >= 0)
			$this->insert($index, $item);
	}
	
	public function find($caption){
		return _c( menu_find($this->self, (string)$caption) );
	}
	
	public function get_index(){
		return menu_index($this->self);
	}
	
	public function indexOf(TMenuItem $item){
		
		return menu_indexOf($this->self, $item->self);
	}
	
	public function get_parent(){
		
		return _c(menu_parent($this->self));
	}
}

class TMenu extends TControl {
	public $class_name = __CLASS__;
	
	function set_images(TImageList $images){
		imagelist_set_images($this->self, $images->self);
	}
}

class TPopupMenu extends TControl {
	public $class_name = __CLASS__;
	

	function popup($x,$y){
		
		popup_popup($this->self, (int)$x, (int)$y);
	}
	
	function addItem(TMenuItem $item, $parent_item = false){
		
		if ($parent_item)
			$parent_item->addItem($item);
		else
			popup_additem($this->self, $item->self);
	}
	
	function set_images(TImageList $images){
		imagelist_set_images($this->self, $images->self);
	}
	
	function get_items(){
		$result = array();
		for ($i=0;$i<popup_item_count($this->self)-1;$i++){
			$result[] = _c(popup_item_id($i));
		}
		
		return $result;
	}
	
	function isShow(){
		
		return popup_isshow($this->self);
	}
}
//=======================================================//
// ImageType
$_c->itImage = 0;
$_c->itMask  = 1;

// DrawingStyle
$_c->setConstList (array('dsFocus', 'dsSelected', 'dsNormal', 'dsTransparent'), 0);

class TImageList extends TControl {
    
    public $class_name = __CLASS__;
    
    #public $imageType = (itImage, itMask)
    #public $blendColor
    #public $bkColor
    #public $masked = (true, false)
    #public $width
    #public $height
    #public $drawingStyle = (dsFocus, dsSelected, dsNormal, dsTransparent)
    
    function addFromFile($file, $color = 0){
        
        $tmp = new TBitmap;
        $tmp->loadAnyFile( $file );
        return $this->altAdd($tmp, $color);
    }
    
    function add(TBitmap $image, TBitmap $mask){
        return imagelist_add($this->self, $image->self, $mask->self);
    }
    
    function altAdd(TBitmap $image, $color = 0){
        imagelist_altadd($this->self, $image->self, $color);
    }
    
    function addMasked(TBitmap $image, $color){
        return imagelist_add_masked($this->self, $image->self, $color);
    }
    
    function insert($index, TBitmap $image, TBitmap $mask){
        return imagelist_insert($this->self, $index, $image->self, $mask->self);
    }
    
    function insertMasked($index, TBitmap $image, $color = 0){
        imagelist_insertmasked($this->self, $index, $image->self, $color);
    }
    
    function move($curIndex, $newIndex){
        imagelist_move($curIndex, $newIndex);
    }
    
    function delete($index){
        imagelist_delete($this->self, $index);
    }
    
    function getBitmap($index, TBitmap $image){
        return imagelist_get_bitmap($this->self, $index, $image->self);
    }
    
    function get_images($index){
        $bmp = new TBitmap;
        $this->getBitmap($index, $bmp);
        return $bmp;
    }
    
    function get_count(){
        return imagelist_count($this->self);
    }
    
    function get_xwidth(){
        
        return $this->get_prop('width');
    }
    
    function set_xwidth($v){
        $this->set_prop('width',$v);
    }
    
    function get_xheight(){
        return $this->get_prop('height');
    }
    
    function set_xheight($v){
        $this->set_prop('height',$v);
    }
}
//=======================================================//
//include_lib('main','web'); //import "CEF4SE";
//=======================================================//
class TStringGrid extends TControl {
    
    public $class_name = __CLASS__;
    #public filename
    
    function setOption($name, $value = true, $ex = false){
		
		$options = array();
		if ($ex)
			$tmp = explode(',',$this->optionsEx);
		else {
			$tmp = explode(',',$this->options);
		}
		
		foreach ($tmp as $el)
		if ($el)
			$options[] = trim($el);
		
		
			
		$k = array_search($name, (array)$options);
			
		if (!$value){
			if ($k!==false)
				unset($options[$k]);
		} else {
			if ($k===false)
				$options[] = $name;
		}
		
		if ($ex){
			$this->optionsEx = implode(',', (array)$options);
		}
		else
			$this->options = implode(',', (array)$options);
	}
	
	function getOption($name, $ex = false){
		
		if ($ex)
		if (stripos($this->optionsEx, $name)!==false)
			return true;
		if (!$ex)
		if (stripos($this->options, $name)!==false)
			return true;
		
		return false;
	}
    
    
    function save($head = true){
        
        $this->saveFile($this->filename, $head);
    }
    
    function load($head = true){
        
        $this->loadFile($this->filename, $head);
    }
    
    function clear(){
        
        $this->colCount = 1;
        $this->rowCount = 1;
        $this->cells(0,0, '');
    }
    
    function setString($str, $head = true){
        
        $tmp = explode(_BR_, $str);
        $arr = array();
        
        if (!$head){
            foreach ($tmp as $line){
                $arr[] = explode(chr(9), $line);
            }
        } else {
            $colNames = explode(chr(9), $tmp[0]);
            
            for ($i=1;$i<count($tmp);$i++){
                $line = explode(chr(9), $tmp[$i]);
                
                $result = array();
                
                foreach ($colNames as $id=>$name)
                $result[$name] = $line[$id];
                
                $arr[] = $result;
            }
        }
        
        $this->setArray($arr, $head);
    }
    
    function getString($head = true){
        
        $arr = $this->getArray($head);
	
	
        if ($head){
	    $tmp[] = implode(chr(9), array_keys($arr[0]));    
	}
	
        foreach ($arr as $line){
            
            $tmp[] = implode(chr(9), $line);
        }
        
        return implode(_BR_, $tmp);
    }
    
    function loadFile($filename, $head = true){
        
        $filename = getFileName($filename);
        $str = file_get_contents($filename);
        $this->setString($str, $head);
    }
    
    function saveFile($filename, $head = true){
        
        $filename = replaceSl($filename);
        $str = $this->getString($head);
        file_put_contents($filename, $str);
    }
    
    // генерируем таблицу по массиву...
    function setArray(array $arr, $head = true){
        
        $this->clear();
        $rowCount = count($arr)+1; // кол-во строк...
        if ($rowCount == 1) return;
        
        
        if (!$head){
            
            $this->rowCount = count($arr);
            $this->colCount = count(current($arr));
            foreach ($arr as $i=>$line){
                $this->rows($i, $line);
            }
            
            return;
        }
        
        // получаем названия колонок по ключам из первого массива..
        $colNames = array_keys($arr[0]);
        $colCount = count($colNames); // кол-во колонк... 
        
        $this->colCount = $colCount;
        $this->rowCount = $rowCount;
        
        $this->fixedRows = (int)$head;
        
        // $row is array
        // $col is int
        
        $this->rows(0, $colNames); // задаем шапку таблицы
        
        $x = 1;
        foreach ($arr as $colName => $rows){
            
            $this->rows($x, $rows);
            $x++;
        }
    }
    
    function getArray($head = true){
        
        $rowCount = $this->rowCount;
        $colCount = $this->colCount;
        $result   = array();
            
        if ($head){
            
            $colNames = $this->rows(0); // достаем заголовки...
            
            for ($i=1; $i<$rowCount; $i++){
                
                $rows = $this->rows($i);
		
                foreach ($colNames as $x=>$colName){
                    
                    $rows[$colName] = $rows[$x];
                    unset($rows[$x]);
                }
                
                $result[] = $rows;
            }
            
        } else {
            
            for ($i=0; $i<$rowCount; $i++){
                 
                $result[] = $this->rows($i);
            }
        }
        
        return $result;
    }
    
    // задаем или получаем значени ячейки x,y
    function cells($x, $y, $value = null){
        
        if ($value===null)
            return grid_cells($this->self, $x, $y, null);
        else
            grid_cells($this->self, $x, $y, $value);
    }
    
    function get_col(){
        return grid_col($this->self, null);
    }
    
    function set_col($v){
        grid_col($this->self, (int)$v);
    }
    
    function get_row(){
        return grid_row($this->self, null);
    }
    
    function set_row($v){
        grid_row($this->self, $v);
    }
    
    // задаем строке в таблице массив...
    function rows($y, $arr = null){
        
        if ($arr !== null){
            if (is_array($arr))
                $arr = implode(_BR_, $arr);
                
            grid_rows($this->self, (int)$y, $arr);
        } else {
            $result = explode(_BR_, grid_rows($this->self, (int)$y, null));
            unset($result[count($result)-1]);
            return $result;
        }
    }
    
    // задаем колонку для таблицы
    function cols($x, $arr = null){
        
        if ($arr !== null){
            if (is_array($arr))
                $arr = implode(_BR_, $arr);
                
            grid_cols($this->self, (int)$x, $arr);
        } else {
            $result = explode(_BR_, grid_cols($this->self, (int)$x, null));
            unset($result[count($result)-1]);
            return $result;
        }
    }
    
    function mouseCoord($x, $y){
        
        return grid_mouseCoord($this->self, (int)$x, (int)$y);
    }
    
    // достаем координаты ячейки по координатам $x, $y
    function mouseToCell($x, $y){
        
        return grid_mouseToCell($this->self, $x, $y);
    }
    
    function get_rowSelect(){ return $this->getOption('goRowSelect'); }
    function set_rowSelect($v){ $this->setOption('goRowSelect', $v); }
    
    function get_focusSelected(){ return $this->getOption('goDrawFocusSelected'); }
    function set_focusSelected($v){ $this->setOption('goDrawFocusSelected', $v); }
    
    function get_editing(){ return $this->getOption('goEditing'); }
    function set_editing($v){ $this->setOption('goEditing', $v); }
    
    function get_hLine(){ return $this->getOption('goHorzLine'); }
    function set_hLine($v){ $this->setOption('goHorzLine',$v); }
    
    function get_vLine(){ return $this->getOption('goVertLine'); }
    function set_vLine($v){ $this->setOption('goVertLine',$v); }
    
    function get_vLineFixed(){ return $this->getOption('goFixedVertLine'); }
    function set_vLineFixed($v){ $this->setOption('goFixedVertLine',$v); }
    
    function get_hLineFixed(){ return $this->getOption('goFixedHorzLine'); }
    function set_hLineFixed($v){ $this->setOption('goFixedHorzLine',$v); }
    
    function get_rowSizing(){ return $this->getOption('goRowSizing'); }
    function set_rowSizing($v){ $this->setOption('goRowSizing', $v); }
    
    function get_colSizing(){ return $this->getOption('goColSizing'); }
    function set_colSizing($v){ $this->setOption('goColSizing', $v); }
    
    function get_colMoving(){ return $this->getOption('goColMoving'); }
    function set_colMoving($v){ $this->setOption('goColMoving', $v); }
    
    function get_rowMoving(){ return $this->getOption('goRowMoving'); }
    function set_rowMoving($v){ $this->setOption('goRowMoving', $v); }
    
    function get_tabs(){ return $this->getOption('goTabs'); }
    function set_tabs($v){ $this->setOption('goTabs',$v); }
}
//=======================================================//
//include_lib('main','registry');
//=======================================================//


//=======================================================//
//include_lib('main','keyboard');
//=======================================================//
//include_lib('main','localization');
//=======================================================//
//include_lib('main','osapi');
//=======================================================//
function toObject($obj){
    
    if (is_numeric($obj))
        $obj = _c($obj);
    elseif (!is_object($obj))
        $obj = c($obj);
    
    return $obj;
}

function control_xywh($self, $nm, $val = null){
    
    switch ($nm){
        
        case 'x': return control_x($self, $val);
        case 'y': return control_y($self, $val);
        case 'w': return control_w($self, $val);
        case 'h': return control_h($self, $val);
    }
}

function cursor_real_x($obj, $offset = 0){
    
    $x = cursor_pos_x();
    $w = $GLOBALS['SCREEN']->Width - 20;
    $x = $x + $offset;
    
    if (is_object($obj))
        $aw = $obj->w;
    else
        $aw = control_w($obj, null);    
    
    if ($x + $aw > $w)
        $x = $x - $aw - $offset*2;
        
    return $x;
}

function cursor_real_y($obj, $offset = 0){
    
    $y = cursor_pos_y();
    $h = $GLOBALS['SCREEN']->Height - 20;
    $y = $y + $offset;
    
    if (is_object($obj))
        $ah = $obj->h;
    else
        $ah = control_h($obj, null);    
        
    if ($y + $ah > $h)
        $y = $y - $ah - $offset*2;
    
    return $y;
}

function findContrastColor($color){
    
    $color = abs($color);
    $color = dechex($color);
  
    if (strlen($color)==3){
        $r = hexdec($color[0]);
        $g = hexdec($color[1]);
        $b = hexdec($color[2]);
    } else {
        $r = hexdec($color[0].$color[1]);
        $g = hexdec($color[2].$color[3]);
        $b = hexdec($color[4].$color[5]);
    }
    
    if ($g < 160) $result = clWhite;
    else $result = clBlack;
    
    return $result;
}

function toHTMLColor($color){
    
    return sprintf('#%02X%02X%02X', $color&0xFF , ($color>>8)&0xFF , ($color>>16)&0xFF );
}


function registerGlobalVar(&$value){
    
    $c = count($GLOBALS[__FUNCTION__]);
    
    $GLOBALS[__FUNCTION__][$c+1] =& $value;
    return $c+1;
}

function &getGlobalVar($index){
    
    return $GLOBALS['registerGlobalVar'][$index];
}

function unsetGlobalVar($index){
    
    $GLOBALS['registerGlobalVar'][$index] = null;
}



class group {
        
    public $objects;
    
    static function toLink($obj){
        
        if (is_object($obj))
            return $obj->self;
        elseif (is_numeric($obj))
            return $obj;
        else
            return c($obj)->self;
    }
    
    function parse($expr){
        
        $prs = explode(',',$expr);
        foreach ($prs as $pr){
            $this->regExpr(trim($pr));
        }
    }
    
    function formRegExpr($str){
        
        global $SCREEN;
        $forms  = $SCREEN->formList();
        $result = array();
        foreach ($forms as $el)
            if (eregi($str, $el->name))
                $result[] = $el;
                
        return $result;
    }
    
    function regExpr($str){
        
        $lines = explode('->', $str);
        
            if ($GLOBALS['__ownerComponent'])
		$onwer = c($GLOBALS['__ownerComponent']);
	    else
		$onwer = $SCREEN->activeForm;
                
        if (count($lines)>1){
            
            $onwers = $this->formRegExpr($lines[0]);
            
            foreach ($onwers as $onwer){
                $links = $onwer->componentLinks;
                foreach ($links as $link){
                    
                    $name = component_name($link);
                    if (eregi($lines[1],$name))
                        $this->addObject($link);
                }
            }
            
        } elseif (count($lines)==1) {
                
            $links = $onwer->componentLinks;
           
            foreach ($links as $link){
                $name = component_name($link);
                if (eregi($str,$name)){
                    $this->addObject($link);
                }
            }
        }
    }
    
    public function __construct($objects = false){
        
        if ($objects)
        $this->setArray($objects);
    }
    
    public function setArray($objects){
        
        if (!is_array($objects)){
            $objects = explode(',',$objects);
            foreach ($objects as $i=>$el)
                $objects[$i] = trim($el);
        }
        
        $c = count($objects);
        for ($i=0; $i<$c; $i++){
            $this->addObject($objects[$i]);
        }
    }
    
    public function clear(){
        
        $this->objects = array();
    }
    
    public function addObject($obj){
        
        $obj = self::toLink($obj);
        
        if (!in_array($obj, (array)$this->objects))
            $this->objects[] = $obj;
    }
    
    static function set($self, $nm, $value){
        
        if (in_array(strtolower($nm),array('x','y','w','h')))
            return control_xywh($self, $nm, $value);
        
        _c($self)->$nm = $value;
    }
    
    function __call($name, $args){
        
        if (!method_exists($this, $name)){
            
            foreach ((array)$this->objects as $obj){
                call_user_func(array(_c($obj), $name), $args);
            }
        }
    }
    
    function __set($nm, $val){
        
        if (property_exists($this, $nm)){
            $this->$nm = $val;
            return;
        }
        
        foreach ((array)$this->objects as $self){
            
            self::set($self, $nm, $val);
        }
    }
}

class TGroup extends group { }
//=======================================================//
//include_lib('main','skins');
//=======================================================//


//=======================================================//
// TSCState = (scsReady, scsMoving, scsSizing);
$_c->setConstList('scsReady', 'scsMoving', 'scsSizing', 0);

class TSizeCtrl extends TControl{
    
    public $class_name = __CLASS__;
    public $targets = array();
    //public $targets_ex = array();
    
    public function set_enable($b){ sizectrl_enable($this->self, $b); }
    public function get_enable()  { return sizectrl_enable($this->self, null); }
    
    public function set_popupMenu($menu){
        
        popup_set($menu->self, $this->self);
    }
    
    public function indexOf($target){        
        $result = 0;
        $self   = $target->self;
        $c      = count($this->targets);
        for($i=0;$i<$c;$i++){
            
            if ($this->targets[$i]->self == $self)
                return $i;
        }
        
        return -1;
    
        foreach ($this->targets as $obj){
            if ($obj->self == $target->self)
                return $result;
            
            $result++;
        }
        return -1;
    }
    
    public function addTarget($target, $init = true){
        
        //$this->targets_ex[$target->self] = $target;
        
       // if ($this->indexOf($target)>-1) return -1;
        
        $this->targets[] = $target;
        
        if ($init)
        return sizectrl_add_target($this->self, $target->self);
    }
    
    public function deleteTarget($target){
        /*$id = $this->indexOf($target);
        if ($id > -1){
            //unset($this->targets_ex[$target->self]);
            unset($this->targets[$id]);
        }
        else return;
        */
        sizectrl_delete_target($this->self, $target->self);
    }
    
    public function unRegisterTarget($target){
        
        
        //unset($this->targets_ex[$target->self]);
        sizectrl_unregister($this->self, $target->self);
    }
    
    public function registerTarget($target){
        
        sizectrl_register($this->self, $target->self);
    }
    
    public function clearTargets(){
        
        sizectrl_clear_targets($this->self);
        $this->targets = array();
        //$this->targets_ex = array();
    }
    
    public function unRegisterAll(){
        sizectrl_unregister_all($this->self);
        $this->targets = array();
        //$this->targets_ex = array();
    }
    
    public function update(){
        sizectrl_update($this->self);
        $this->targets_ex = array();
    }
    
    public function updateBtns(){
        sizectrl_updateBtns($this->self);
    }
    
    public function getSelected(){
        
        return sizectrl_selected($this->self);
    }
    
    public function get_targets_ex(){
        
        $result = array();
            $tmp = $this->getSelected();
            foreach ($tmp as $link)
                $result[$link] = _c($link);
                
        return $result;
    }
    
    public function set_onSizeMouseDown($value){
        $this->onMouseDown = $value;
    }
    
}
//=======================================================//
class TEditBtn extends TPanel {
    
    const BUTTON_HEIGTH = 26;
    
    public $btn;
    public $edit;
    
    public $class_name_ex = __CLASS__;
    
    function set_onSelectClick($str){
        
        $this->btn->onClick = $str;
    }
    
    function set_onKeyPress($str){
        
        $this->edit->onKeyPress = $str;
    }
    
    function set_onKeyUp($str){
        
        $this->edit->onKeyUp = $str;
    }
    
    function set_onKeyDown($str){
        
        $this->edit->onKeyDown = $str;
    }
    
    function set_onChange($str){
        
        $this->edit->onChange = $str;
    }
    
    function __initComponentInfo(){
        
        $this->createComponents();
        $this->initComponents();
        $this->text = $this->atext;
        $this->readOnly = $this->areadOnly;
        $this->caption = $this->acaption;
    }
    
    function __construct($onwer=nil,$init=true,$self=nil){
        parent::__construct($onwer,$init,$self);
        $this->bevelOuter = 'bvNone';
        
        
        if ($init){
            $this->text = '';
            $this->createComponents();
        } else {
            $this->edit = _c($this->edit_link);
            $this->btn  = _c($this->btn_link);
        }
        
        $this->initComponents();
        $this->__setAllPropEx($init);
    }
    
    function createComponents(){
            $this->btn  = new TBitBtn($this);
            $this->btn->parent  = $this;
            
            $this->edit = new TEdit($this);
            $this->edit->parent = $this;
            //$this->edit->height = self::BUTTON_HEIGTH;
            
            $this->edit->name = 'edit';
            $this->btn->name  = 'btn';
            
            $this->edit->text   = '';
            $this->btn->caption = '...';
            
            $this->edit_link = $this->edit->self;
            $this->btn_link  = $this->btn->self;
            
            $this->height = $this->edit->h + 2;
    }
    
    function initComponents(){
        
        $this->caption = ' ';
        $this->edit->left = 0;
        $this->edit->top = 0;
        //$this->edit->height = self::BUTTON_HEIGTH;
        
        $this->edit->width = $this->width - self::BUTTON_HEIGTH - 4;
    
        $this->edit->anchors = 'akLeft, akRight, akTop';
        
        $this->btn->top = 0;
        $this->btn->width = self::BUTTON_HEIGTH;
        $this->btn->height = $this->edit->height;
        $this->btn->left = $this->width - self::BUTTON_HEIGTH;
        $this->caption = ' ';

        $this->btn->anchors = 'akRight, akTop';
        //$this->__getAddSource();
    }
    
    function set_text($v){
        $this->edit->text = $v;
        $this->atext = $v;
    }
    
    function get_text(){
        return $this->edit->text;
    }
    
    function set_caption($v){
        $this->btn->text = $v;
        $this->acaption = $v;
    }
    
    function get_caption(){
        return $this->btn->text;
    }
    
    function set_readOnly($v){
        $this->edit->readOnly = (bool)$v;
        $this->areadOnly = (bool)$v;
    }
    
    function get_readOnly(){
        return $this->edit->readOnly;
    }
    
    function __set($name, $value){
        parent::__set($name, $value);
        
        if ($name=='name'){
            $this->text = $value;
        }
            
        $this->initComponents();
    }
}


class TEditDialog extends TEditBtn {
    
    public $dlg;
    public $dlg_type;
    public $class_name_ex = __CLASS__;
    
    function __initComponentInfo(){
        
        parent::__initComponentInfo();
        
        $class = $this->dlg_type;
        $this->dlg = new $class($this);
        $this->dlg->name = 'dlg';
        $this->filter = $this->afilter;
    }
    
    function __construct($onwer=nil,$init=true,$self=nil){
        parent::__construct($onwer,$init,$self);
        
        $class = $this->dlg_type;
        
        if ($class)
        if ($init){
            $this->dlg = new $class($this);
            //$this->dlg->name = 'dlg';
            $this->dlg_link = $this->dlg->self;
        } else {
            $this->dlg = _c($this->dlg_link);//$this->findComponent('dlg');
        }
        
        $this->onSelectClick = $this->class_name_ex . '::selectDialog';
        $this->__setAllPropEx($init);
    }
    
    function selectDialog($self){
        
        $obj = _c(_c($self)->owner);
        
        if ($obj->dlg->execute()){
            $obj->text = $obj->dlg->fileName;
            
            if ($obj->onSelect)                   
                eval($obj->onSelect . "(".$obj->self.",'" . $obj->dlg->fileName . "');");
        }
        
    }
    
    function set_onSelect($v){
        $this->onSelect = $v;
    }
    
    function set_filter($v){
        
        $this->dlg->filter = $v;
        $this->afilter = $v;
    }
    
    function get_filter($v){
        return $this->dlg->filter;
    }
}

class TEditOpenDialog extends TEditDialog {
    
    public $class_name_ex = __CLASS__;
    
    function __construct($onwer=nil,$init=true,$self=nil){
        $this->dlg_type = 'TOpenDialog';
        parent::__construct($onwer,$init,$self);
    }
}

class TEditSaveDialog extends TEditDialog {
    
    public $class_name_ex = __CLASS__;
    
    function __construct($onwer=nil,$init=true,$self=nil){
        $this->dlg_type = 'TSaveDialog';
       
        parent::__construct($onwer,$init,$self);
         
    }
}


class TEditFontDialog extends TEditDialog {
    
    public $class_name_ex = __CLASS__;
    
    function __construct($onwer=nil,$init=true,$self=nil){
        $this->dlg_type = 'TFontDialog';
       
        parent::__construct($onwer,$init,$self);
        
        $this->readOnly = true;
        $this->text = '(Настройки Шрифта)';
    }
    
    function selectDialog($self){
        
        $obj = _c(_c($self)->owner);
        
        if ($obj->dlg->execute()){
            $obj->value = $obj->dlg->font;
            if ($obj->onSelect){
                $font = $obj->dlg->font;
                eval($obj->onSelect . '(' . $obj->self . ',$font);');
            }
            
        } 
    }
    
    function set_value($font){
        $last_size = $this->edit->font->size;
        $this->edit->font->assign($font);
        $this->dlg->font->assign($font);
        $this->edit->font->size = $last_size;
    }
    
    function get_value(){
        return $this->dlg->font;
    }
}

class TEditColorDialog extends TEditDialog {
    
    public $class_name_ex = __CLASS__;
    
    function __initComponentInfo(){
        
        parent::__initComponentInfo();
        $this->color = $this->acolor;
    }
    
    function __construct($onwer=nil,$init=true,$self=nil){
        $this->dlg_type = 'TColorDialog';
       
        parent::__construct($onwer,$init,$self);
        
        $this->readOnly = true;
        $this->value    = $this->dlg->color;
        $this->__setAllPropEx();
    }
    
    function selectDialog($self){
        
        $obj = _c(_c($self)->owner);
        
        if ($obj->dlg->execute()){
            $obj->value = $obj->dlg->color;
            if ($obj->onSelect){
                
                $color = $obj->dlg->color;
                eval($obj->onSelect . '(' . $obj->self . ',$color);');
            }
            
        } 
    }
    
    function set_value($color){
        if ($color == clNone){
            $this->edit->text  = 'None';
            $this->edit->color = clWhite;
        }
        else{
            $this->edit->text  = '0x'.dechex($color);
            $this->edit->color = $color;
        }
        
        
        $this->dlg->color  = $color;
        $this->acolor = $color;
    }
    
    function get_value(){
        return $this->dlg->color;
    }
}

class TEditDMSColorDialog extends TEditDialog {
    
    public $class_name_ex = __CLASS__;
    
    function __construct($onwer=nil,$init=true,$self=nil){
       
        parent::__construct($onwer,$init,$self);
            
        if ($init)
            $this->readOnly = true;
        
        $this->__setAllPropEx($init);
    }
    
    function selectDialog($self){
        
        $obj = _c(_c($self)->owner);
        $dlg = new TDMSColorDialog;
        $dlg->color = $obj->value;
        
        $x = cursor_real_x($dlg->form,10);
        $y = cursor_real_y($dlg->form,10);
        
        if ($dlg->execute($x, $y)){
            $obj->value = $dlg->color;
            if ($obj->onSelect){
                
                $color = $dlg->color;
                eval($obj->onSelect . '(' . $obj->self . ',$color);');
            }
        }
        
        $dlg->free();
    }
    
    function set_value($color){
        
        $this->edit->fontColor = findContrastColor($color);
        $this->edit->color = $color;
        $this->edit->text  = '0x'.dechex($color);
        $this->acolor = $color;
    }
    
    function get_value(){
        return $this->acolor;
    }
}
//=======================================================//
//include_lib('design','dfmparser');
//=======================================================//


//=======================================================//
// TSynEdit =============================================//
$_c->setConstList(array('ctCode', 'ctHint', 'ctParams'),0);
class TSynEdit extends TMemo {
    
    public $class_name = __CLASS__;
    
    #public $ActiveLineColor : TColor
    #public $Align : TAlign
    #public $Anchors : TAnchors
    #public $BookMarkOptions : TSynBookMarkOpt
    #public $BorderStyle : TBorderStyle
    #public $Color : TColor
    #public $Constraints : TSizeConstraints
    #public $Ctl3D : Boolean
    #public $Enabled : Boolean
    #public $ExtraLineSpacing : Integer
    #public $Font : TFont
    #public $FontSmoothing : TSynFontSmoothMethod
    #public $Gutter : TSynGutter
    #public $HideSelection : Boolean
    #public $Highlighter : TSynCustomHighlighter
    #public $ImeMode : TImeMode
    #public $ImeName : TImeName
    #public $InsertCaret : TSynEditCaretType
    #public $InsertMode : Boolean
    #public $Keystrokes : TSynEditKeyStrokes
    #public $Lines : TUnicodeStrings
    #public $MaxScrollWidth : Integer
    #public $MaxUndo : Integer
    #public $OnChange : TNotifyEvent
    #public $OnClearBookmark : TPlaceMarkEvent
    #public $OnClick : TNotifyEvent
    #public $OnCommandProcessed : TProcessCommandEvent
    #public $OnContextHelp : TContextHelpEvent
    #public $OnDblClick : TNotifyEvent
    #public $OnDragDrop : TDragDropEvent
    #public $OnDragOver : TDragOverEvent
    #public $OnDropFiles : TDropFilesEvent
    #public $OnEndDock : TEndDragEvent
    #public $OnEndDrag : TEndDragEvent
    #public $OnEnter : TNotifyEvent
    #public $OnExit : TNotifyEvent
    #public $OnGutterClick : TGutterClickEvent
    #public $OnGutterGetText : TGutterGetTextEvent
    #public $OnGutterPaint : TGutterPaintEvent
    #public $OnKeyDown : TKeyEvent
    #public $OnKeyPress : TKeyPressWEvent
    #public $OnKeyUp : TKeyEvent
    #public $OnMouseCursor : TMouseCursorEvent
    #public $OnMouseDown : TMouseEvent
    #public $OnMouseMove : TMouseMoveEvent
    #public $OnMouseUp : TMouseEvent
    #public $OnMouseWheel : TMouseWheelEvent
    #public $OnMouseWheelDown : TMouseWheelUpDownEvent
    #public $OnMouseWheelUp : TMouseWheelUpDownEvent
    #public $OnPaint : TPaintEvent
    #public $OnPaintTransient : TPaintTransient
    #public $OnPlaceBookmark : TPlaceMarkEvent
    #public $OnProcessCommand : TProcessCommandEvent
    #public $OnProcessUserCommand : TProcessCommandEvent
    #public $OnReplaceText : TReplaceTextEvent
    #public $OnScroll : TScrollEvent
    #public $OnSpecialLineColors : TSpecialLineColorsEvent
    #public $OnStartDock : TStartDockEvent
    #public $OnStartDrag : TStartDragEvent
    #public $OnStatusChange : TStatusChangeEvent
    #public $Options : TSynEditorOptions
    #public $OverwriteCaret : TSynEditCaretType
    #public $ParentColor : Boolean
    #public $ParentCtl3D : Boolean
    #public $ParentFont : Boolean
    #public $ParentShowHint : Boolean
    #public $PopupMenu : TPopupMenu
    #public $ReadOnly : Boolean
    #public $RightEdge : Integer
    #public $RightEdgeColor : TColor
    #public $ScrollBars : TScrollStyle
    #public $ScrollHintColor : TColor
    #public $ScrollHintFormat : TScrollHintFormat
    #public $SearchEngine : TSynEditSearchCustom
    #public $SelectedColor : TSynSelectedColor
    #public $SelectionMode : TSynSelectionMode
    #public $ShowHint : Boolean
    #public $TabOrder : TTabOrder
    #public $TabStop : Boolean
    #public $TabWidth : Integer
    #public $Visible : Boolean
    #public $WantReturns : Boolean
    #public $WantTabs : Boolean
    #public $WordWrap : Boolean
    #public $WordWrapGlyph : TSynGlyph
}

class TSynCompletionProposal extends TControl {
    
    public $class_name = __CLASS__;
    public $itemList; // TStrings
    public $insertList; // TStrings
    
    #clBackground = clWindow
    #clSelect = clHighlight
    #clSelectText = clHighlightText
    #clTitleBackground = clBtnFace
    
    #margin = 2
    #itemHeight = 0
    #nbLinesInWindow = 8
    #resizeable = true
    #defaultType = ctCode
    #shortCut = CTRL+SPACE
    #title = ''
    #width = 260
    
    function __construct($onwer=nil,$init=true,$self=nil){
		parent::__construct($onwer,$init,$self);
		$this->itemList = new TStrings(false);
		$this->itemList->self = __rtii_link($this->self,'itemList');
			
			$this->insertList = new TStrings(false);
		$this->insertList->self = __rtii_link($this->self,'insertList');
		
		$this->__setAllPropEx();
    }
    
    public function setEditor(TSynEdit $editor){
	
		syncomplete_editor($this->self, $editor->self);
    }
    
    public function get_visible(){
	return (syncomplete_visible($this->self));
    }
    
    public function get_insert(){
        return $this->insertList->get_text();
    }
    public function set_insert($text){
        $this->insertList->text = $text;
    }
    
    public function get_item(){
        return $this->itemList->get_text();   
    }
    public function set_item($text){
	$this->itemList->text = $text;
    }
    
    public function set_editor(TSynEdit $editor){
        syncomplete_editor($this->self, $editor->self);
    }
    
    public function get_editor(){
        return _c(syncomplete_editor($this->self, null));
    }
    
    public function set_shortCut($sc){
		
	if (!is_numeric($sc))
		$sc = text_to_shortcut(strtoupper($sc));
	$this->set_prop('shortCut',$sc);
    }
	
    public function get_shortCut(){
		
	$result = $this->get_prop('shortCut');
	return shortCut_to_text($result);
    }
    
    public function active($value = true){
        
        syncomplete_activate($this->self, (bool)$value);
    }
    
    public function get_hint(){
        return $this->insertList->text;
    }
    
    public function set_hint($hint){
        $this->defaultType      = ctParams;
        $this->insertList->text = $hint;
        $this->itemList->text   = $hint;
    }
    
    public function get_currentString(){
	
	return syncomplete_currentString($this->self);
    }
    
    public function get_empty(){
	
	return syncomplete_empty($this->self);
    }
}

class TSynHighlighterAttributes extends TControl {
	
	public $class_name = __CLASS__;
	#TColor background
	#TColor foreground
	#string style = 'fsBold, fsItalic, fsStrikeOut, fsUnderline'
}

class TSynCustomHighlighter extends TControl {
	
	public $class_name = __CLASS__;
	#enabled
	#DefaultFilter 
	
	// ->getAttri('Comment')->background = clGray;
	function getAttri($prefix = 'Comment'){
		
		$prop = $prefix . 'Attri';
		
		$result = new TSynHighlighterAttributes(nil,false);
		$result->self = gui_propGet($this->self, $prop);
		return $result;
	}
}

#attr: Comment, Identifier, Key, Number, Space, String, Symbol, Variable
class TSynPHPSyn extends TSynCustomHighlighter {
	public $class_name = __CLASS__;
	static $prefixs = array('Comment', 'Identifier', 'Key', 'Number', 'Space', 'String', 'Symbol', 'Variable');
	
	function saveAttr($prefix, &$arr){
		
		$attr = $this->getAttri($prefix);
		$arr[$prefix]['background'] = $attr->background;
		$arr[$prefix]['foreground'] = $attr->foreground;
		$arr[$prefix]['style']      = $attr->style;
	}
	
	function saveToArray(&$arr){
		
		foreach (self::$prefixs as $prefix)
			$this->saveAttr($prefix, $arr);
	}
	
	function loadFromArray($arr){
		
		foreach (self::$prefixs as $prefix){
			$attr = $this->getAttri($prefix);
			if (isset($arr[$prefix])){
				$attr->background = $arr[$prefix]['background'];
				$attr->foreground = $arr[$prefix]['foreground'];
				$attr->style      = $arr[$prefix]['style'];
			}
		}
	}
}
class TSynGeneralSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynCppSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynCssSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynHTMLSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynSQLSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynJScriptSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
class TSynXMLSyn extends TSynCustomHighlighter { public $class_name = __CLASS__; }
//=======================================================//


//=======================================================//
$GLOBALS['SCREEN'] = new TScreenEx;
$GLOBALS['APPLICATION'] = to_object(get_application(),'TApplication');

define('SoulEngine_Loaded',true, false);
//=======================================================//