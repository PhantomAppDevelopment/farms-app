package searchScreens
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class StateDetailsScreen extends PanelScreen
	{
		public static const GO_FARM_DETAILS:String = "goFarmDetails";
		
		private var farmsArray:Array;
		private var tempArray:Array;
		
		private var citiesInput:TextInput;
		private var farmsList:List
		private var myStatement:SQLStatement;
		
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
			this.title = _data.selectedState.State;
			this.layout = new VerticalLayout();;
			this.backButtonHandler = goBack;
			
			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			citiesInput = new TextInput();
			citiesInput.height = 35;
			citiesInput.width = 200;
			citiesInput.prompt = "Type a City name";
			this.headerProperties.centerItems = new <DisplayObject>[citiesInput];
						
			farmsList = new List();
			farmsList.hasElasticEdges = false;
			farmsList.itemRendererFactory = function():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function(item:Object):String
				{
					return "<b>" + item.MarketName + "</b>" + "\n" + item.street + "\n" + item.city + ", " + item.zip;
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
			farmsList.layoutData = new VerticalLayoutData(100, 100);
			this.addChild(farmsList);
			
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}		
		
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			
			if(_data.savedResults){
				farmsArray = _data.stateFarms;				
				farmsList.dataProvider = _data.savedResults;
				farmsList.scrollToDisplayIndex(_data.selectedIndex);
				farmsList.selectedIndex = _data.selectedIndex;
				citiesInput.text = _data.citiesInputText;
				
				farmsList.addEventListener(Event.CHANGE, changeHandler);
				citiesInput.addEventListener(Event.CHANGE, inputHandler);

			} else {
				farmsList.addEventListener(Event.CHANGE, changeHandler);
				citiesInput.addEventListener(Event.CHANGE, inputHandler);
				
				doSearch();
			}
		}
		
		private function doSearch():void
		{			
			myStatement = new SQLStatement();
			myStatement.sqlConnection = FarmsApp.conn;
			myStatement.addEventListener(SQLEvent.RESULT, onResult);				
			var myQuery:String = "SELECT * FROM farms WHERE State='"+_data.selectedState.State+"'";
			myStatement.text = myQuery;
			myStatement.execute();
		}
		
		private function onResult(event:SQLEvent):void
		{
			var result:SQLResult = myStatement.getResult();
			farmsList.dataProvider = new ListCollection(farmsArray = result.data);
		}
		
		private function changeHandler(event:Event):void
		{
			_data.selectedFarm = farmsList.selectedItem;
			_data.selectedIndex = farmsList.selectedIndex;
			_data.savedResults = farmsList.dataProvider;
			_data.stateFarms = farmsArray;
			_data.citiesInputText = citiesInput.text;
			dispatchEventWith(GO_FARM_DETAILS);
		}
		
		private function inputHandler(event:Event):void
		{
			farmsList.removeEventListener(Event.CHANGE, changeHandler);
			farmsList.dataProvider = new ListCollection(tempArray = farmsArray.filter(filterCities));
			farmsList.addEventListener(Event.CHANGE, changeHandler);
		}
		
		private function filterCities(item:Object, index:int, arr:Array):Boolean {
			return item.city.match(new RegExp(citiesInput.text, "i"));
		}
		
		private function goBack():void
		{		
			_data.selectedFarm = null;
			_data.selectedIndex = null;
			_data.savedResults = null;
			_data.stateFarms = null;
			_data.citiesInputText = null;
			
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
	}
}