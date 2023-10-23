package src
{
   import flash.display.*;
   import flash.events.*;
   import flash.external.*;
   import flash.net.*;
   import flash.system.*;
   
   public class MainTimeline extends MovieClip
   {
      
      public static var Game:Object;
       
      
      private const sTitle:String = "Champion of Doom";
      
      private const sURL:String = "https://game.aq.com/game/";
      
      private const versionURL:String = "https://game.aq.com/game/api/data/gameversion";
      
      private var sFile:String;
      
      private var sBG:String;
      
      private var isEU:Boolean;
      
      private var urlLoader:URLLoader;
      
      private var loader:Loader;
      
      private var loaderVars:Object;
      
      private var stg:*;
      
      public function MainTimeline()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage);
      }
      
      private function OnAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage);
         Security.allowDomain("*");
         trace("Fixed by gulag");
         this.urlLoader = new URLLoader();
         this.urlLoader.addEventListener(Event.COMPLETE,this.OnDataComplete);
         this.urlLoader.load(new URLRequest(this.versionURL));
      }
      
      private function OnDataComplete(param1:Event) : void
      {
         this.urlLoader.removeEventListener(Event.COMPLETE,this.OnDataComplete);
         var _loc2_:Object = JSON.parse(param1.target.data);
         this.sFile = _loc2_.sFile;
         this.sBG = _loc2_.sBG;
         this.isEU = _loc2_.isEU;
         this.loaderVars = _loc2_;
         this.LoadGame();
      }
      
      private function LoadGame() : void
      {
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.OnComplete);
         this.loader.load(new URLRequest(this.sURL + "gamefiles/" + this.sFile));
      }
      
      private function OnComplete(param1:Event) : void
      {
         this.Externalize();
         this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.OnComplete);
         this.stg = stage;
         this.stg.removeChildAt(0);
         Game = this.stg.addChild(MovieClip(Loader(param1.target.loader).content));
         Game.params.sURL = this.sURL;
         Game.params.sTitle = this.sTitle;
         Game.params.sBG = this.sBG;
         Game.params.isEU = this.isEU;
         Game.params.loginURL = "https://game.aq.com/game/api/login/now";
         Game.sfc.addEventListener(SFSEvent.onConnectionLost,this.OnDisconnect);
         Game.loginLoader.addEventListener(Event.COMPLETE,this.OnLoginComplete);
         addEventListener(Event.ENTER_FRAME,this.EnterFrame);
      }
      
      private function OnDisconnect(param1:*) : void
      {
         ExternalInterface.call("disconnect");
      }
      
      private function OnLoginComplete(param1:Event) : void
      {
         trace("Login Complete");
      }
      
      private function EnterFrame(param1:Event) : void
      {
         var _loc2_:* = undefined;
         if(Game.mcLogin != null && Game.mcLogin.ni != null && Game.mcLogin.pi != null && Game.mcLogin.btnLogin != null)
         {
            removeEventListener(Event.ENTER_FRAME,this.EnterFrame);
            _loc2_ = Game.mcLogin.btnLogin;
            this.CatchPackets();
            _loc2_.addEventListener(MouseEvent.CLICK,this.OnLoginClick);
         }
      }
      
      private function OnLoginClick(param1:MouseEvent) : void
      {
         var _loc2_:* = Game.mcLogin.btnLogin;
         _loc2_.removeEventListener(MouseEvent.CLICK,this.OnLoginClick);
      }
      
      private function CatchPackets() : void
      {
         Game.sfc.addEventListener(SFSEvent.onDebugMessage,this.PacketReceived);
      }
      
      private function StopCatching() : void
      {
         Game.sfc.removeEventListener(SFSEvent.onDebugMessage,this.PacketReceived);
      }
      
      private function PacketReceived(param1:*) : void
      {
         var _loc2_:String = this.GetPacket(param1.params.message);
         ExternalInterface.call("packet",_loc2_);
      }
      
      private function GetPacket(param1:String) : String
      {
         var _loc2_:* = "[Sending - STR]: ";
         var _loc3_:* = "[ RECEIVED ]: ";
         if(param1.indexOf(_loc2_) > -1)
         {
            return param1.replace(_loc2_,"");
         }
         if(param1.indexOf(_loc3_) > -1)
         {
            return param1.replace(_loc3_,"");
         }
         return param1;
      }
      
      private function SendPacket(param1:String) : *
      {
         var _loc2_:* = [];
         var _loc3_:* = "";
         var _loc4_:* = "";
         var _loc5_:* = "";
         var _loc6_:* = false;
         var _loc7_:* = false;
         var _loc8_:* = false;
         var _loc9_:* = false;
         var _loc10_:* = 1;
         while(_loc10_ < param1.length)
         {
            if(param1.charAt(_loc10_) != "%")
            {
               if(_loc6_ && !_loc7_)
               {
                  _loc4_ += param1.charAt(_loc10_);
               }
               else if(_loc6_ && _loc7_ && !_loc8_)
               {
                  _loc5_ += param1.charAt(_loc10_);
               }
               else if(_loc6_ && _loc7_ && _loc8_ && _loc9_)
               {
                  _loc3_ += param1.charAt(_loc10_);
               }
            }
            else if(!_loc6_)
            {
               _loc6_ = true;
            }
            else if(_loc6_ && !_loc7_)
            {
               _loc7_ = true;
            }
            else if(_loc6_ && _loc7_ && !_loc8_)
            {
               _loc8_ = true;
            }
            else if(_loc6_ && _loc7_ && _loc8_ && !_loc9_)
            {
               _loc9_ = true;
            }
            else if(_loc6_ && _loc7_ && _loc8_ && _loc9_)
            {
               _loc2_.push(_loc3_);
               _loc3_ = "";
            }
            _loc10_++;
         }
         var _loc11_:* = Game.world.curRoom;
         switch(_loc5_)
         {
            case "afk":
               _loc11_ = "1";
               break;
            case "hi":
               _loc11_ = "1";
               break;
            case "gar":
               _loc11_ = "1";
               break;
            case "cmd":
               _loc11_ = "1";
         }
         Game.world.rootClass.sfc.sendXtMessage(_loc4_,_loc5_,_loc2_,"str",_loc11_);
      }
      
      public function IsLoggedIn() : String
      {
         return MainTimeline.Game != null && MainTimeline.Game.sfc.isConnected == true ? "True" : "False";
      }
      
      public function Login() : void
      {
         Game.login(Game.mcLogin.ni.text,Game.mcLogin.pi.text);
      }
      
      public function Logout() : void
      {
         Game.logout();
      }
      
      public function Connect(param1:String) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in Game.serialCmd.servers)
         {
            if(_loc2_.sName == param1)
            {
               Game.objServerInfo = _loc2_;
               Game.chatF.iChat = _loc2_.iChat;
               break;
            }
         }
         Game.connectTo(Game.objServerInfo.sIP,Game.objServerInfo.iPort);
      }
      
      private function Externalize() : void
      {
         ExternalInterface.addCallback("CatchPackets",this.CatchPackets);
         ExternalInterface.addCallback("StopCatching",this.StopCatching);
         ExternalInterface.addCallback("SendPacket",this.SendPacket);
         ExternalInterface.addCallback("Login",this.Login);
         ExternalInterface.addCallback("Logout",this.Logout);
         ExternalInterface.addCallback("Connect",this.Connect);
         ExternalInterface.addCallback("IsLoggedIn",this.IsLoggedIn);
      }
   }
}
