package screens
{
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.PanelScreen;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class MapScreen extends PanelScreen
	{
		private var geoMap:GeoMap;
		
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
			this.title = "Map View";
			this.backButtonHandler = goBack;
			this.layout = new AnchorLayout();
			
			this.headerProperties.paddingLeft = 10;
			
			var doneIcon:ImageLoader = new ImageLoader();
			doneIcon.source = "assets/icons/check.png";
			doneIcon.width = doneIcon.height = 25;
			
			var doneButton:Button = new Button();
			doneButton.defaultIcon = doneIcon;
			doneButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			doneButton.styleNameList.add("header-button");
			this.headerProperties.rightItems = new <DisplayObject>[doneButton];
			
			var mapOptions:MapOptions = new MapOptions();
			mapOptions.initialScale = 4/32;
			mapOptions.maximumScale = 1/32;
			mapOptions.disableRotation = true;
			
			geoMap = new GeoMap(mapOptions);
			geoMap.visible = false;
			geoMap.layoutData = new AnchorLayoutData(0, 0, 0, 0, NaN, NaN);
			this.addChild(geoMap);
			
			var osMaps:MapLayerOptions = Maps.OSM;
			osMaps.notUsedZoomThreshold = 1;
			geoMap.addLayer("osMaps", osMaps);
			
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}
		
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			
			geoMap.setCenterLongLat(_data.selectedFarm.x, _data.selectedFarm.y);
			geoMap.visible = true;
			
			var finalMarker:ImageLoader = new ImageLoader();
			finalMarker.source = "assets/icons/person_pin.png";
			finalMarker.width = finalMarker.height = 50;
			finalMarker.color = 0x2E7D32;
			finalMarker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
			geoMap.addMarkerLongLat("final", _data.selectedFarm.x, _data.selectedFarm.y, finalMarker);
		}
		
		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
	}
}