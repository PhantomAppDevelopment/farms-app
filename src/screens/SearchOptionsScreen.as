package screens
{
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.events.Event;
	
	public class SearchOptionsScreen extends Screen
	{
		public static const GO_STATES:String = "goStates";
		public static const GO_ZIP:String = "goZip";
		
		private var backButton:Button;
		private var storeButton:Button;
		private var mapButton:Button;
		
		override protected function initialize():void
		{
			this.backButtonHandler = goBack;
			this.layout = new AnchorLayout();
			
			var layoutForMainGroup:HorizontalLayout = new HorizontalLayout();
			layoutForMainGroup.gap = 20;
			
			var mainGroup:LayoutGroup = new LayoutGroup();
			mainGroup.layout = layoutForMainGroup;
			mainGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			this.addChild(mainGroup);
			
			var backIcon:ImageLoader = new ImageLoader();
			backIcon.width = backIcon.height = 75;
			backIcon.pixelSnapping = true;
			backIcon.source = "assets/icons/back.png";
			
			backButton = new Button();
			backButton.addEventListener(Event.TRIGGERED, goBack);
			backButton.alpha = 0;
			backButton.scaleX = backButton.scaleY = 0;
			backButton.styleNameList.add("home-button");
			backButton.label = "Go Back";
			backButton.defaultIcon = backIcon;
			mainGroup.addChild(backButton);
			
			var storeIcon:ImageLoader = new ImageLoader();
			storeIcon.width = storeIcon.height = 75;
			storeIcon.pixelSnapping = true;
			storeIcon.source = "assets/icons/store.png";
			
			storeButton = new Button();
			storeButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_STATES);
			});
			storeButton.alpha = 0;
			storeButton.scaleX = storeButton.scaleY = 0;
			storeButton.styleNameList.add("home-button");
			storeButton.label = "States";
			storeButton.defaultIcon = storeIcon;
			mainGroup.addChild(storeButton);
			
			var mapIcon:ImageLoader = new ImageLoader();
			mapIcon.width = mapIcon.height = 75;
			mapIcon.pixelSnapping = true;
			mapIcon.source = "assets/icons/map.png";
			
			mapButton = new Button();
			mapButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_ZIP);
			});
			mapButton.alpha = 0;
			mapButton.scaleX = mapButton.scaleY = 0;
			mapButton.styleNameList.add("home-button");
			mapButton.label = "ZIP Codes";
			mapButton.defaultIcon = mapIcon;
			mainGroup.addChild(mapButton);
			
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}
		
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			
			var tween1:Tween = new Tween(backButton, 0.3);
			tween1.animate("alpha", 1);
			tween1.animate("scaleX", 1);
			tween1.animate("scaleY", 1);
			tween1.onComplete = function():void
			{
				Starling.juggler.add(tween2);
			};
			
			var tween2:Tween = new Tween(storeButton, 0.3);
			tween2.animate("alpha", 1);
			tween2.animate("scaleX", 1);
			tween2.animate("scaleY", 1);
			tween2.onComplete = function():void
			{
				Starling.juggler.add(tween3);
			}
			
			var tween3:Tween = new Tween(mapButton, 0.3);
			tween3.animate("alpha", 1);
			tween3.animate("scaleX", 1);
			tween3.animate("scaleY", 1); 
			
			Starling.juggler.add(tween1);
		}
		
		private function goBack():void
		{
			this.dispatchEventWith(Event.COMPLETE);
		}
	}
}