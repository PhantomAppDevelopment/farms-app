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
	
	public class StatesScreen extends PanelScreen
	{
		public static const GO_STATE_DETAILS:String = "goStateDetails";
		
		private var statesInput:TextInput;
		private var statesList:List;
		private var myStatement:SQLStatement;
		
		private var statesArray:Array;
		private var tempArray:Array;
		
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
			this.title = "Search by State";
			this.layout = new VerticalLayout();;
			this.backButtonHandler = goBack;
			
			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			statesInput = new TextInput();
			statesInput.height = 35;
			statesInput.width = 200;
			statesInput.prompt = "Type a State name";
			this.headerProperties.centerItems = new <DisplayObject>[statesInput];
						
			statesList = new List();
			statesList.itemRendererFactory = function():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function(item:Object):String
				{
					return "<b>" + item.State + "</b>" + "\n" + item.count + " entries";
	;			};
				
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
			statesList.layoutData = new VerticalLayoutData(100, 100);
			this.addChild(statesList);
			
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}
	
		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
							
			if(_data.savedStates){
				statesArray = _data.statesArray;
				statesList.dataProvider = _data.savedStates;
				statesList.scrollToDisplayIndex(_data.selectedStateIndex);
				statesList.selectedIndex = _data.selectedStateIndex;
				statesInput.text = _data.stateInputText;				
				
				statesList.addEventListener(Event.CHANGE, changeHandler);
				statesInput.addEventListener(Event.CHANGE, inputHandler);

			} else {
				statesList.addEventListener(Event.CHANGE, changeHandler);
				statesInput.addEventListener(Event.CHANGE, inputHandler);

				loadStatesList();
			}
		}
		
		private function changeHandler(event:Event):void
		{
			_data.selectedState = statesList.selectedItem;
			_data.selectedStateIndex = statesList.selectedIndex;
			_data.statesArray = statesArray;
			_data.savedStates = statesList.dataProvider;
			_data.stateInputText = statesInput.text;
			dispatchEventWith(GO_STATE_DETAILS);
		}
		
		private function loadStatesList():void
		{			
			myStatement = new SQLStatement();
			myStatement.sqlConnection = FarmsApp.conn;
			myStatement.addEventListener(SQLEvent.RESULT, loadStates);
			
			var myQuery:String = "SELECT State, count(*) as count FROM farms group by State";

			myStatement.text = myQuery;
			myStatement.execute();
		}
		
		private function loadStates(event:SQLEvent):void
		{
			var result:SQLResult = myStatement.getResult();
			statesList.dataProvider = new ListCollection(statesArray = result.data);
		}
		
		private function inputHandler(event:Event):void
		{
			statesList.removeEventListener(Event.CHANGE, changeHandler);
			statesList.dataProvider = new ListCollection(tempArray = statesArray.filter(filterStates));
			statesList.addEventListener(Event.CHANGE, changeHandler);
		}
		
		private function filterStates(item:Object, index:int, arr:Array):Boolean {
			return item.State.match(new RegExp(statesInput.text, "i"));
		}
		
		private function goBack():void
		{		
			_data.selectedState = null;
			_data.selectedStatesIndex = null;
			_data.savedStates = null;
			_data.statesArray = null;
			
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
		
		
	}
}