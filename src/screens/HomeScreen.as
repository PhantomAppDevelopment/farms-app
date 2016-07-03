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
	
	public class HomeScreen extends Screen
	{
		public static const GO_SEARCH_OPTIONS:String = "goSearchOptions";
		public static const GO_GPS:String = "goGPS";
		public static const GO_BOOKMARKS:String = "goBookmarks";
		
		private var searchButton:Button;
		private var nearButton:Button;
		private var bookmarkButton:Button;
		
		override protected function initialize():void
		{			
			this.layout = new AnchorLayout();
			
			var layoutForMainGroup:HorizontalLayout = new HorizontalLayout();
			layoutForMainGroup.gap = 20;
			
			var mainGroup:LayoutGroup = new LayoutGroup();
			mainGroup.layout = layoutForMainGroup;
			mainGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			this.addChild(mainGroup);
			
			var searchIcon:ImageLoader = new ImageLoader();
			searchIcon.width = searchIcon.height = 75;
			searchIcon.pixelSnapping = true;
			searchIcon.source = "assets/icons/search.png";
			
			searchButton = new Button();
			searchButton.alpha = 0;
			searchButton.scaleX = searchButton.scaleY = 0;
			searchButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_SEARCH_OPTIONS);
			});
			searchButton.styleNameList.add("home-button");
			searchButton.label = "Search";
			searchButton.defaultIcon = searchIcon;
			mainGroup.addChild(searchButton);
			
			var nearIcon:ImageLoader = new ImageLoader();
			nearIcon.width = nearIcon.height = 75;
			nearIcon.pixelSnapping = true;
			nearIcon.source = "assets/icons/near.png";
			
			nearButton = new Button();
			nearButton.alpha = 0;
			nearButton.scaleX = nearButton.scaleY = 0;
			nearButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_GPS);
			});
			nearButton.styleNameList.add("home-button");
			nearButton.label = "Near Me";
			nearButton.defaultIcon = nearIcon;
			mainGroup.addChild(nearButton);
			
			var bookmarkIcon:ImageLoader = new ImageLoader();
			bookmarkIcon.width = bookmarkIcon.height = 75;
			bookmarkIcon.pixelSnapping = true;
			bookmarkIcon.source = "assets/icons/bookmark.png";
			
			bookmarkButton = new Button();
			bookmarkButton.alpha = 0;
			bookmarkButton.scaleX = bookmarkButton.scaleY = 0;
			bookmarkButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_BOOKMARKS);
			});
			bookmarkButton.styleNameList.add("home-button");
			bookmarkButton.label = "Bookmarks";
			bookmarkButton.defaultIcon = bookmarkIcon;
			mainGroup.addChild(bookmarkButton);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}
		
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			
			var tween1:Tween = new Tween(searchButton, 0.3);
			tween1.animate("alpha", 1);
			tween1.animate("scaleX", 1);
			tween1.animate("scaleY", 1);
			tween1.onComplete = function():void
			{
				Starling.juggler.add(tween2);
			};
			
			var tween2:Tween = new Tween(nearButton, 0.3);
			tween2.animate("alpha", 1);
			tween2.animate("scaleX", 1);
			tween2.animate("scaleY", 1); 
			tween2.onComplete = function():void
			{
				Starling.juggler.add(tween3);
			}
			
			var tween3:Tween = new Tween(bookmarkButton, 0.3);
			tween3.animate("alpha", 1);
			tween3.animate("scaleX", 1);
			tween3.animate("scaleY", 1); 
			
			Starling.juggler.add(tween1);
		}
			
	}
}