package
{
		
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.motion.Cover;
	import feathers.motion.Fade;
	import feathers.motion.Reveal;
	
	import screens.DirectionsScreen;
	import screens.FarmDetailsScreen;
	import screens.HomeScreen;
	import screens.MapScreen;
	import screens.SearchOptionsScreen;
	
	import searchScreens.BookmarksScreen;
	import searchScreens.GPSScreen;
	import searchScreens.StateDetailsScreen;
	import searchScreens.StatesScreen;
	import searchScreens.ZipScreen;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Main extends Sprite
	{
		private var conn:SQLConnection;
		private var myStatement:SQLStatement;
		
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private var myNavigator:StackScreenNavigator;
		
		private static const HOME_SCREEN:String = "homeScreen";
		private static const SEARCH_OPTIONS_SCREEN:String = "searchOptionsScreen";
		private static const GPS_SCREEN:String = "GPSScreen";
		private static const BOOKMARKS_SCREEN:String = "bookmarksScreen";
		private static const ZIP_SCREEN:String = "zipScreen";
		private static const STATES_SCREEN:String = "statesScreen";
		private static const STATE_DETAILS_SCREEN:String = "stateDetailsScreen";
		private static const FARM_DETAILS_SCREEN:String = "farmDetailsScreen";
		private static const DIRECTIONS_SCREEN:String = "directionsScreen";
		private static const MAP_SCREEN:String = "mapScreen";
		
		protected function addedToStageHandler(event:starling.events.Event):void
		{			
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			
			new CustomTheme();
			
			var NAVIGATOR_DATA:NavigatorData = new NavigatorData();
			
			myNavigator = new StackScreenNavigator();
			myNavigator.pushTransition = Fade.createFadeOutTransition();
			myNavigator.popTransition = Fade.createFadeOutTransition();
			addChild(myNavigator);

			var homeScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HomeScreen);
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_SEARCH_OPTIONS, SEARCH_OPTIONS_SCREEN);
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_GPS, GPS_SCREEN);
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_BOOKMARKS, BOOKMARKS_SCREEN);
			myNavigator.addScreen(HOME_SCREEN, homeScreenItem);
						
			var searchOptionsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SearchOptionsScreen);
			searchOptionsScreenItem.addPopEvent(Event.COMPLETE);
			searchOptionsScreenItem.setScreenIDForPushEvent(SearchOptionsScreen.GO_STATES, STATES_SCREEN);
			searchOptionsScreenItem.setScreenIDForPushEvent(SearchOptionsScreen.GO_ZIP, ZIP_SCREEN);
			myNavigator.addScreen(SEARCH_OPTIONS_SCREEN, searchOptionsScreenItem);
			
			var gpsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(GPSScreen);
			gpsScreenItem.properties.data = NAVIGATOR_DATA;
			gpsScreenItem.addPopEvent(Event.COMPLETE);
			gpsScreenItem.setScreenIDForPushEvent(GPSScreen.GO_FARM_DETAILS, FARM_DETAILS_SCREEN);
			myNavigator.addScreen(GPS_SCREEN, gpsScreenItem);
			
			var bookmarksScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(BookmarksScreen);
			bookmarksScreenItem.properties.data = NAVIGATOR_DATA;
			bookmarksScreenItem.addPopEvent(Event.COMPLETE);
			bookmarksScreenItem.setScreenIDForPushEvent(StateDetailsScreen.GO_FARM_DETAILS, FARM_DETAILS_SCREEN);
			myNavigator.addScreen(BOOKMARKS_SCREEN, bookmarksScreenItem);
			
			var zipScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ZipScreen);
		 	zipScreenItem.properties.data = NAVIGATOR_DATA;
			zipScreenItem.addPopEvent(Event.COMPLETE);
			zipScreenItem.setScreenIDForPushEvent(ZipScreen.GO_FARM_DETAILS, FARM_DETAILS_SCREEN);
			myNavigator.addScreen(ZIP_SCREEN, zipScreenItem);
			
			var statesScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(StatesScreen);
			statesScreenItem.properties.data = NAVIGATOR_DATA;
			statesScreenItem.addPopEvent(Event.COMPLETE);
			statesScreenItem.setScreenIDForPushEvent(StatesScreen.GO_STATE_DETAILS, STATE_DETAILS_SCREEN);
			myNavigator.addScreen(STATES_SCREEN, statesScreenItem);
			
			var stateDetailsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(StateDetailsScreen);
			stateDetailsScreenItem.properties.data = NAVIGATOR_DATA;
			stateDetailsScreenItem.addPopEvent(Event.COMPLETE);
			stateDetailsScreenItem.setScreenIDForPushEvent(StateDetailsScreen.GO_FARM_DETAILS, FARM_DETAILS_SCREEN);
			myNavigator.addScreen(STATE_DETAILS_SCREEN, stateDetailsScreenItem);
			
			var farmDetailsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(FarmDetailsScreen);
			farmDetailsScreenItem.properties.data = NAVIGATOR_DATA;
			farmDetailsScreenItem.addPopEvent(Event.COMPLETE);
			farmDetailsScreenItem.setScreenIDForPushEvent(FarmDetailsScreen.GO_DIRECTIONS, DIRECTIONS_SCREEN);
			farmDetailsScreenItem.setScreenIDForPushEvent(FarmDetailsScreen.GO_MAP, MAP_SCREEN);
			myNavigator.addScreen(FARM_DETAILS_SCREEN, farmDetailsScreenItem);
			
			var directionsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DirectionsScreen);
			directionsScreenItem.pushTransition = Cover.createCoverUpTransition();
			directionsScreenItem.popTransition = Reveal.createRevealDownTransition();
			directionsScreenItem.properties.data = NAVIGATOR_DATA;
			directionsScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(DIRECTIONS_SCREEN, directionsScreenItem);
			
			var mapScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MapScreen);
			mapScreenItem.pushTransition = Cover.createCoverUpTransition();
			mapScreenItem.popTransition = Reveal.createRevealDownTransition();
			mapScreenItem.properties.data = NAVIGATOR_DATA;
			mapScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(MAP_SCREEN, mapScreenItem);
			
			
			myNavigator.rootScreenID = HOME_SCREEN;

		}
	}
}