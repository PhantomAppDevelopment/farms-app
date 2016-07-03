package searchScreens
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TabBar;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class BookmarksScreen extends PanelScreen
	{
		public static const GO_FARM_DETAILS:String = "goFarmDetails";
				
		private var farmsList:List;
		private var geoMap:GeoMap;
		private var tabBar:TabBar;
		
		protected var _data:NavigatorData;
		
		public function get data():NavigatorData
		{
			return this._data;
		}		
		
		public function set data(value:NavigatorData):void
		{
			this._data = value;	
		}
		
		override protected function initialize():void
		{
			this.title = "Bookmarks";
			this.layout = new AnchorLayout();
			this.backButtonHandler = goBack;
			
			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			farmsList = new List();
			farmsList.addEventListener(Event.CHANGE, function():void
			{
				_data.selectedFarm = farmsList.selectedItem;
				_data.selectedIndex = farmsList.selectedIndex;
				_data.fromBookmarks = true;
				dispatchEventWith(GO_FARM_DETAILS);
			});
			farmsList.itemRendererFactory = function():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function(item:Object):String
				{
					return "<b>" + item.MarketName + "</b>" + "\n" + item.street + "\n" + item.city + ", " + item.State + ", " + item.zip;
				}
				
				renderer.accessorySourceFunction = function():String
				{
					return "assets/icons/chevron.png";
				}
				
				renderer.accessoryLoaderFactory = function():ImageLoader
				{
					var loader:ImageLoader = new ImageLoader();
					loader.width = loader.height = 25;
					return loader;
				}
				
				return renderer;
			};
			farmsList.layoutData = new AnchorLayoutData(0, 0, 50, 0, NaN, NaN);
			this.addChild(farmsList);
			
			var listIcon:ImageLoader = new ImageLoader();
			listIcon.source = "assets/icons/list.png";
			listIcon.width = listIcon.height = 25;
			
			var pinIcon:ImageLoader = new ImageLoader();
			pinIcon.source = CustomTheme.pinTexture;
			pinIcon.width = pinIcon.height = 25;
			
			var mapOptions:MapOptions = new MapOptions();
			mapOptions.initialScale = 1/128;
			mapOptions.maximumScale = 1/2;
			mapOptions.disableRotation = true;
			
			geoMap = new GeoMap(mapOptions);
			geoMap.visible = false;
			geoMap.layoutData = new AnchorLayoutData(0, 0, 50, 0, NaN, NaN);
			addChild(geoMap);
			
			var osMaps:MapLayerOptions = Maps.OSM;
			osMaps.notUsedZoomThreshold = 1;
			geoMap.addLayer("osMaps", osMaps);
			
			tabBar = new TabBar();
			tabBar.addEventListener(Event.CHANGE, tabHandler);
			tabBar.height = 50;
			tabBar.layoutData = new AnchorLayoutData(NaN, 0, 0, 0, NaN, NaN);
			tabBar.dataProvider = new ListCollection(
				[
					{label:"", data:"list", defaultIcon:listIcon},
					{label:"", data:"map", defaultIcon:pinIcon}				
				]);
			this.addChild(tabBar);
			
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}
		
		private function tabHandler(event:Event):void
		{
			if(tabBar.selectedIndex == 0){
				farmsList.visible = true;
				geoMap.visible = false;
			} else if(tabBar.selectedIndex == 1){
				farmsList.visible = false;
				
				if(farmsList.dataProvider != null && farmsList.dataProvider.length >= 1){
					geoMap.setCenterLongLat(farmsList.dataProvider.getItemAt(0).x, farmsList.dataProvider.getItemAt(0).y);
					geoMap.removeAllMarkers();
					geoMap.visible = true;
					
					for each(var item:Object in farmsList.dataProvider.data) {
						
						var marker:ImageLoader = new ImageLoader();
						marker.source = CustomTheme.pinTexture;
						marker.color = 0xCC0000;
						marker.width = marker.height = 50;
						marker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
						
						geoMap.addMarkerLongLat(String(item.FMID), 
							Number(item.x),
							Number(item.y), marker);	
					}					
				}				
			} else {
				
			}
		}
		
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			
			loadBookmarks();			
		}
		
		private function loadBookmarks():void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("bookmarks.data");
			
			if(file.exists)
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				
				if(fileStream.bytesAvailable == 0){					
					fileStream.close();				
				} else {
					var bookmarksArray:Array = fileStream.readObject();
					
					farmsList.dataProvider = new ListCollection(bookmarksArray);
					
					fileStream.close();					
				}								
			}
		}
		
		private function goBack():void
		{
			_data.fromBookmarks = null;
			_data.selectedIndex = null;
			
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
		
	}
}