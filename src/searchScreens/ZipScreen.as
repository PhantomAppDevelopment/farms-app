package searchScreens
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;
	
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TabBar;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class ZipScreen extends PanelScreen
	{
		public static const GO_FARM_DETAILS:String = "goFarmDetails";
				
		private var alert:Alert;
		private var farmsList:List;
		private var geoMap:GeoMap;
		private var myStatement:SQLStatement;
		private var tabBar:TabBar;
		private var zipInput:TextInput;
		
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
			this.backButtonHandler = goBack;
			this.layout = new AnchorLayout();
			
			var backButton:Button = new Button();
			backButton.addEventListener(Event.TRIGGERED, goBack);
			backButton.styleNameList.add("back-button");
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			var searchIcon:ImageLoader = new ImageLoader();
			searchIcon.source = "assets/icons/search_icon.png";
			searchIcon.width = searchIcon.height = 25;
						
			var searchButton:Button = new Button();
			searchButton.addEventListener(Event.TRIGGERED, doSearch);
			searchButton.defaultIcon = searchIcon;
			searchButton.styleNameList.add("header-button");
			this.headerProperties.rightItems = new <DisplayObject>[searchButton];
						
			zipInput = new TextInput();
			zipInput.maxChars = 5;
			zipInput.restrict = "0-9";
			zipInput.height = 35;
			zipInput.width = 200;
			zipInput.prompt = "Type a ZIP code";
			this.headerProperties.centerItems = new <DisplayObject>[zipInput];
			
			farmsList = new List();			
			farmsList.itemRendererFactory = function():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function(item:Object):String
				{
					return "<b>" + item.MarketName + "</b>" + "\n" + item.street + "\n" + item.zip;
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
			
			if(_data.savedResults){
				farmsList.dataProvider = _data.savedResults;
				farmsList.scrollToDisplayIndex(_data.selectedIndex);
				farmsList.selectedIndex = _data.selectedIndex;
				zipInput.text = _data.savedZip;
				
				farmsList.addEventListener(Event.CHANGE, changeHandler);
			} else {
				farmsList.addEventListener(Event.CHANGE, changeHandler);
			}				
		}
		
		private function changeHandler(event:Event):void
		{
			_data.selectedFarm = farmsList.selectedItem;
			_data.selectedIndex = farmsList.selectedIndex;
			_data.savedResults = farmsList.dataProvider;
			_data.savedZip = zipInput.text;
			dispatchEventWith(GO_FARM_DETAILS);
		}
		
		private function doSearch():void
		{
			if(zipInput.text == ""){
				alert = Alert.show("Please type a ZIP code and try again.", "Error", new ListCollection(
					[
						{ label: "OK"}
					]) );
			} else {
				myStatement = new SQLStatement();
				myStatement.sqlConnection = FarmsApp.conn;
				myStatement.addEventListener(SQLEvent.RESULT, onResult);
				
				var zip:Number = Number(zipInput.text);
				
				var myQuery:String = "SELECT * FROM farms WHERE zip <='"+(zip+50)+"' AND zip >='"+(zip-50)+"'";
				myStatement.text = myQuery;
				myStatement.execute();			
			}	
		}
		
		private function onResult(event:SQLEvent):void
		{
			var result:SQLResult = myStatement.getResult();
			
			farmsList.removeEventListener(Event.CHANGE, changeHandler);
			farmsList.selectedIndex = -1;
			farmsList.addEventListener(Event.CHANGE, changeHandler);
			
			farmsList.dataProvider = new ListCollection(result.data);
		}
		
		private function goBack():void
		{
			_data.selectedFarm = null;
			_data.selectedIndex = null;
			_data.savedResults = null;
			_data.savedZip = null;
			
			if(alert){
				alert.removeFromParent(true);
			}

			this.dispatchEventWith(Event.COMPLETE);
		}
	}
}