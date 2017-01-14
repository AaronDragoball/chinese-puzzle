package{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Puzzle extends Sprite{
		private var loader:Loader;
		private var picW:int; //外部图片的宽度
		private var picH:int;  //外部图片的高度
		private var picBD:BitmapData;
		private var mySprite:Sprite;
		private var massWidth:int;
		private var massHeight:int;
		private var leaveNum:int;
		private var Time:int = 60;
		private var Time_MC:MovieClip;
		private var Player:MovieClip;
		private var myTimer:Timer;
		private var speed:int=0;
		private var Score_MC:MovieClip;
		private var score:int = 0;
		
		public function Puzzle():void{
			Play_Btn.addEventListener(MouseEvent.CLICK,playGame)
			//侦听开始按钮的鼠标单击事件  调用playGame()函数开始游戏
		}
		private function playGame(e:MouseEvent):void{
			delAll();  //删除开场界面
			loadMC(); //加载游戏界面
			loadPlayer();  //加载卡通人物
			loadJpg();  //加载小图片
			loadTimer();//  加载计时器
			loadScore();  //加载计分器
		}
		private function loadJpg():void{
			var urls:String = "2.jpg";
			var reqs:URLRequest = new URLRequest(urls);
			var loaders:Loader = new Loader();
			loaders.load(reqs);
			this.addChild(loaders);
			loaders.y = 30;
			loaders.x = stage.stageWidth - 200;
		}
		private function loadScore():void{
			Score_MC = new score_mc();
			Score_MC.x = stage.stageWidth-100;
			Score_MC.y = stage.stageHeight-20;
			Score_MC.score_txt.text = score.toString();
			this.addChild(Score_MC);
		}
		private function loadTimer():void{
			Time_MC = new time_mc();//实例化计时器对象
			Time_MC.x = Time_MC.width/2-80;
			Time_MC.y = stage.stageHeight-20;
			//定义计时器的位置
			this.addChild(Time_MC);//将计时器显示在舞台中
			Time_MC.timebar.width = 258;//定义时间进度条的长度
			var delay:int = 1000;//定义间隔时间
			var repeat:int = 100;//定义循环次数
			myTimer = new Timer(delay,repeat);//创建Timer时间对象
			myTimer.addEventListener(TimerEvent.TIMER,startTime);//开始倒计时
			myTimer.start();  //启动计时器
			Time_MC.Time_txt.text = "60s";
			this.addEventListener(Event.ENTER_FRAME,IsFalse);
		}
		private function IsFalse(e:Event):void{
			if(Time<=0){
				this.removeEventListener(Event.ENTER_FRAME,IsFalse);
				stage.mouseChildren = false;
				Time=0;
				Time_MC.Time_txt.text = "0s";
				this.removeChild(Player);
				
				var Falser:falser = new falser();//实例化失败卡通人物
				Falser.x = stage.stageWidth - Falser.width/2-10;
				Falser.y = 75;//定义失败卡通人物的位置
				this.addChild(Falser);//将卡通人显示在舞台中
				
				myTimer.removeEventListener(TimerEvent.TIMER,startTime);
				myTimer.reset();//停止计时，并初始化计时器
			} 
		}
		private function startTime(e:TimerEvent):void{
			Time--;//时间减1
			Time_MC.timebar.width = 258*Time/60;//实现时间进度条缩短
			Time_MC.Time_txt.text = Time +"s";
		}
		private function loadPlayer():void{
			Player = new player();//实例化卡通人
			Player.x = stage.stageWidth - Player.width/2-10;
			Player.y = 75;//定义卡通人的位置
			this.addChild(Player);//将卡通人显示在舞台中	
		}
		private function delAll():void{
			var num:int = this.numChildren;//获取舞台中存在对象的个数
			while(num != 0)//如果个数不为0
			{
				this.removeChildAt(0);//删除舞台最底层的对象
				num--;
			}
		}
		private function loadMC():void{
			var BG:bg = new bg();//实例化背景图像对象
			BG.x = BG.y = 0;//定义背景图像的位置
			this.addChild(BG);//将背景图像显示在舞台中
			var url:String = "1.jpg";//定义外部图片的地址
			var req:URLRequest = new URLRequest(url);
			//创建URLRequest对象，捕获单个HTTP请求中的所有信息
			loader = new Loader();//创建URLLoader对象
			loader.load(req); //开始加载外部图片
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			//侦听加载外部图像完成事件
		}
		public function onComplete(e:Event):void{
			picW = loader.width;//图片的宽度
			picH = loader.height;//图片的高度
			picBD = new BitmapData(picW,picH);//根据加载图像的高宽创建BitmapData对象
			var bitmap:Bitmap=new Bitmap(picBD);//创建位图图像
			picBD.draw(loader.content,null,null,null,null,true);
			//将加载的图片内容绘制到创建位图图像上
			bitmap.alpha = 0.3;//定义位图图像的透明度
			mySprite = new Sprite();
			mySprite.addChild(bitmap);//将位图图像加入到容器中
			mySprite.x=10;//mySprite容器的x坐标
			mySprite.y=30;//mySprite容器的y坐标
			stage.addChild(mySprite);//将mySprite容器显示在舞台中
			copyPixel();//调用copyPixel()函数，将图像裁切成小图片
		}
		private  function copyPixel():void{
			var n:int = 3;  //拼图的横纵向块数
			leaveNum = n * n;//拼图的总块数
			massWidth = Math.round(picW/n);  //小图片的宽
			massHeight = Math.round(picH / n);  //小图片的高
			var massBD:BitmapData;
			var massBitmap:Bitmap;
			var massSprite:Sprite;
			
			for(var i=0;i<n;i++){
				for(var j=0;j<n;j++){
					massBD = new BitmapData(massWidth,massHeight);//创建小图片的位图图像
					massBD.copyPixels(picBD,new Rectangle(i*massWidth,j*massHeight,massWidth,massHeight),new Point(0,0));
					//根据坐标和大小复制图像位图中的矩形区域至小图片上
					massBitmap=new Bitmap(massBD);
					massSprite=new Sprite();
					massSprite.x=stage.stageWidth-225+Math.random()*100;
					massSprite.y=stage.stageHeight-350+Math.random()*150;
					//定义小图片放置的位置
					massSprite.addEventListener(MouseEvent.MOUSE_DOWN,massDown);
					//侦听小图片的鼠标按下事件，调用massDown()函数拖动小图片
					massSprite.addEventListener(MouseEvent.MOUSE_UP,massUp);
					//侦听小图片的鼠标释放事件,调用massUp()函数停止拖动
					massSprite.name="MS"+i+j;//定义小图片的名称
					massSprite.addChild(massBitmap);//将小图片加入可交互显示对象中
					mySprite.addChild(massSprite);//将小图片加入到mySprite容器中
				}
			}
		}
		private function massDown(e:MouseEvent):void{
			e.target.startDrag();//开始拖动图片
			mySprite.addChild(Sprite(e.target));//让拖动的图片显示在最上面
		}
		private function massUp(e:MouseEvent):void{
			e.target.stopDrag();//停止拖动图片
			var pici=Number(e.target.name.charAt(2));
			var picj=Number(e.target.name.charAt(3));
			//获取小图片名称中的位置标识
			if(Math.abs(e.target.x-pici*massWidth)<=20&&Math.abs(e.target.y-picj*massHeight)<=20){
				//如果放置小图片的坐标与正确位置的坐标小于等于20
				e.target.removeEventListener(MouseEvent.MOUSE_UP,massUp);
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN,massDown);
				//删除侦听小图片的鼠标按下和释放事件
				e.target.x=pici*massWidth;
				e.target.y=picj*massHeight;
			    //小图片吸附到正确的位置
				score+=10;
				Score_MC.score_txt.text = score.toString();//分数加10，并显示在计分器中
			    leaveNum--;//小图片剩余个数减1
			    
				if (leaveNum <= 0){
					//如果剩余的小图片个数小于等于0
					this.removeChild(Player);
			    	
					var Winner:winner = new winner();//实例化胜利卡通人物
					Winner.x = stage.stageWidth - Winner.width/2-10;
					Winner.y = 75;//定义胜利卡通人物的位置
					this.addChild(Winner);//将卡通人显示在舞台中
					
					myTimer.removeEventListener(TimerEvent.TIMER,startTime);
					myTimer.reset();//停止计时，并初始化计时器
					
					var Over:over = new over();//实例化结束对象
					Over.x = -Over.width;
					Over.y = stage.stageHeight/2;
					this.addChild(Over);
					Over.addEventListener(Event.ENTER_FRAME,moveTo);
			    }
		     }
		 }
		 private function moveTo(e:Event):void {
			 var mc:MovieClip = e.target as MovieClip;//实例化目标事件对象
			 speed++;//加速度
			 mc.x += speed;//实现向右加速移动
			 stage.addChild(mc);
			 if (mc.x>=stage.stageWidth/4){
				 //如果该对象位于舞台横向的1/4处
				 mc.removeEventListener(Event.ENTER_FRAME,moveTo);//停止移动
			}
		}
	
	}
}