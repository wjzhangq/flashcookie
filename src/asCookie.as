package
{
	import flash.display.Sprite;
	import flash.net.SharedObject;
	import flash.external.ExternalInterface;
	
	public class asCookie extends Sprite
	{
		private var cookieTimeout:uint;
		private var cookieName:String;
		private var cookieShareObj:SharedObject;
		
		
		public function asCookie(cName:String = "ascookieid", timeout:uint=3600 * 24 * 365 * 10)
		{
			cookieName = cName;
			cookieTimeout = timeout;
			cookieShareObj = SharedObject.getLocal(cName, "/");
			ExternalInterface.addCallback("getCookie", getCookie);
			ExternalInterface.addCallback("setCookie", saveCookie);
			ExternalInterface.addCallback('removeCookie', removeCookie);
			ExternalInterface.call('js_ascookie_complete_init');
		}
		
		public function clearTimeout():void{
			var obj:* = cookieShareObj.data.cookie;
			if (obj == undefined){
				return;
			}
			
			for(var key:String in obj){
				if (obj[key] == undefined || obj[key].time == undefined || isTimeout(obj[key].time)){
					delete obj[key]
				}
			}
			
			cookieShareObj.data.cookie = obj;
			cookieShareObj.flush();
		}
		
		
		public function saveCookie(key:String, value:*):void{
			var today:Date = new Date();
			key = "key_" + key;
			value.time = today.getTime();
			if (cookieShareObj.data.cookie == undefined){
				var obj:Object = {};
				obj[key] = value;
				cookieShareObj.data.cookie = obj;
			}else{
				cookieShareObj.data.cookie[key] = value;
			}
			cookieShareObj.flush();
		}
		
		public function getCookie(key:String):Object{
			return isCookieExist(key) ? cookieShareObj.data.cookie["key_" + key]:null;
		}
		
		public function removeCookie(key:String):void{
			if (isCookieExist(key)){
				delete cookieShareObj.data.cookie["key_" + key];
				cookieShareObj.flush();
			}
		}
		
		public function isCookieExist(key:String):Boolean{
			key = "key_" + key;
			return cookieShareObj.data.cookie != undefined && cookieShareObj.data.cookie[key] != undefined;
		}
		
		private function isTimeout(time:uint):Boolean{
			var today:Date = new Date();
			return time + cookieTimeout * 1000 < today.getTime();
		}
		
		public function getTimeout():uint{
			return cookieTimeout;
		}
		
		public function getName():String{
			return cookieName;
		}
		
		public function clearCookies():void{
			cookieShareObj.clear();
		}
	}
}