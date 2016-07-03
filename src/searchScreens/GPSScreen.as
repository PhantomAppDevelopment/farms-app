package searchScreens
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.GeolocationEvent;
	import flash.events.SQLEvent;
	import flash.events.StatusEvent;
	import flash.sensors.Geolocation;
	
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;
	
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.TabBar;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;

	public class GPSScreen extends PanelScreen
	{
		public static const GO_FARM_DETAILS:String = "goFarmDetails";
		
		private var alert:Alert;
		private var farmsList:List;
		private var geoMap:GeoMap;
		private var myStatement:SQLStatement;
		private var optionsPanel:Panel;
		private var tabBar:TabBar;
		
		private var geo:Geolocation;		
		private var distance:Number = 8.04672;
		private var longitude:Number;
		private var latitude:Number;
		private var optionsSavedIndex:Number;
		private var openPopup:Boolean = false;
		
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
			this.title = "Search with GPS";
			this.layout = new AnchorLayout();
			this.backButtonHandler = goBack;
			
			var backButton:Button = new Button();
			backButton.addEventListener(Event.TRIGGERED, goBack);
			backButton.styleNameList.add("back-button");
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			var menuIcon:ImageLoader = new ImageLoader();
			menuIcon.source = "assets/icons/menu.png";
			menuIcon.width = menuIcon.height = 25;
						
			var menuButton:Button = new Button();
			menuButton.addEventListener(Event.TRIGGERED, openMenu);
			menuButton.styleNameList.add("header-button");
			menuButton.defaultIcon = menuIcon;
			this.headerProperties.rightItems = new <DisplayObject>[menuButton];
			
			farmsList = new List();			
			farmsList.itemRendererFactory = function():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function(item:Object):String
				{
					return "<b>" + item.MarketName + "</b>" + "\n" + item.State + "\n" + calculateDistance(latitude, longitude, item.y, item.x);
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
					geoMap.setCenterLongLat(longitude, latitude);
					geoMap.removeAllMarkers();
					
					var userMarker:ImageLoader = new ImageLoader();
					userMarker.width = userMarker.height = 50;
					userMarker.source = "assets/icons/person_pin.png";
					userMarker.color = 0x0000FF;
					userMarker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
					
					geoMap.addMarkerLongLat("user", longitude, latitude, userMarker);
					
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

				if(_data.optionsSavedIndex){
					optionsSavedIndex = _data.optionsSavedIndex
				} else {
					optionsSavedIndex = 0;
				}
				
				farmsList.addEventListener(Event.CHANGE, changeHandler);
			} else {
				
				if (Geolocation.isSupported) { 
					geo = new Geolocation(); 
					
					if (!geo.muted){
						geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler); 
					} else {
						alert = Alert.show("Your GPS is turned off, please turn it ON and try again.", "Error", new ListCollection([{label:"OK", triggered:goBack}]));
					}				
					geo.addEventListener(StatusEvent.STATUS, geoStatusHandler);
				} else {
					alert = Alert.show("GPS is not supported on your device.", "Error", new ListCollection([{label:"OK", triggered:goBack}]));
				}
			}
		}
		
		private function geoUpdateHandler(event:GeolocationEvent):void 
		{
			optionsSavedIndex = 0;
			_data.optionsSavedIndex = 0;
			farmsList.addEventListener(Event.CHANGE, changeHandler);
			
			latitude = event.latitude;
			longitude = event.longitude;
			
			geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			geo = null;			
			
			doSearch();
		} 
		
		private function geoStatusHandler(event:StatusEvent):void 
		{ 
			if (geo.muted) {
				geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			} else {
				geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			}
		}
		
		private function changeHandler(event:Event):void
		{
			_data.selectedFarm = farmsList.selectedItem;
			_data.selectedIndex = farmsList.selectedIndex;
			_data.savedResults = farmsList.dataProvider;
			dispatchEventWith(GO_FARM_DETAILS);
		}
		
		private function doSearch():void
		{
			myStatement = new SQLStatement();
			myStatement.sqlConnection = FarmsApp.conn;
			myStatement.addEventListener(SQLEvent.RESULT, onResult);
									
			var latitudeDistance:Number = 1.0 / 111.1 * distance;
			var longitudeDistance:Number = 1.0 / Math.abs(111.1*Math.cos(latitude)) * distance;
			
			var myQuery:String = "SELECT * FROM farms WHERE y BETWEEN "+(latitude - latitudeDistance)+" AND "+(latitude + latitudeDistance)+
				" AND x BETWEEN "+(longitude - longitudeDistance)+" AND "+(longitude + longitudeDistance);
			myStatement.text = myQuery;
			myStatement.execute();			
			
		}

		private function onResult(event:SQLEvent):void
		{
			var result:SQLResult = myStatement.getResult();
			farmsList.dataProvider = new ListCollection(result.data);
		}

		private function calculateDistance(lat1:Number,lon1:Number,	lat2:Number, lon2:Number):String
		{			
			var R:int = 6378;
					
			var dLat:Number = (lat2-lat1) * Math.PI/180;
			var dLon:Number = (lon2-lon1) * Math.PI/180;
			
			var lat1inRadians:Number = lat1 * Math.PI/180;
			var lat2inRadians:Number = lat2 * Math.PI/180;
			
			var a:Number = Math.sin(dLat/2) * Math.sin(dLat/2) + 
				Math.sin(dLon/2) * Math.sin(dLon/2) * 
				Math.cos(lat1inRadians) * Math.cos(lat2inRadians);
			var c:Number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
			var d:Number = R * c;
			
			return Math.round(d*0.621371).toString() + " mi.";
		}
		
		private function openMenu(event:Event):void
		{
			openPopup = true;
			
			optionsPanel = new Panel();
			optionsPanel.headerProperties.paddingLeft = 10;
			optionsPanel.title = "Select a Distance";
			
			var options:ListCollection = new ListCollection(
				[
					{label:"5 mi.", data:8.04672},
					{label:"10 mi.", data:16.0934},
					{label:"20 mi.", data:32.1869}
				]);
			
			var optionsList:List = new List();
			optionsList.width = optionsList.maxWidth = 200;
			optionsList.minHeight = 100;
			optionsList.dataProvider = options;
			optionsList.hasElasticEdges = false;
			optionsPanel.addChild(optionsList);

			optionsList.selectedIndex = optionsSavedIndex;
			
			optionsList.addEventListener(Event.CHANGE, function():void
			{
				farmsList.removeEventListener(Event.CHANGE, changeHandler);
				farmsList.selectedIndex = -1;
				distance = optionsList.selectedItem.data;
				_data.optionsSavedIndex = optionsList.selectedIndex;
				optionsSavedIndex = optionsList.selectedIndex;
				PopUpManager.removePopUp(optionsPanel, true);
				openPopup = false;
				doSearch();
				farmsList.addEventListener(Event.CHANGE, changeHandler);
			});			
			
			PopUpManager.addPopUp(optionsPanel, true, true, function():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;				
			});
		}
		
		private function goBack():void
		{
			_data.selectedFarm = null;
			_data.selectedIndex = null;
			_data.savedResults = null;
			_data.optionsSavedIndex = 0;
			
			if (geo){
				geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
				geo = null;
			}
			
			if(alert){
				alert.removeFromParent(true);
			}
			
			if(openPopup){
				PopUpManager.removePopUp(optionsPanel, true);
			}
			
			this.dispatchEventWith(Event.COMPLETE);
		}
	}
}