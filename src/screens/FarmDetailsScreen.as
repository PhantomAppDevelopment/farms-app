package screens
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import feathers.controls.Alert;
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PanelScreen;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class FarmDetailsScreen extends PanelScreen
	{
		public static const GO_DIRECTIONS:String = "goDirections";
		public static const GO_MAP:String = "goMap";
		
		private var alert:Alert;
		
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
			
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 10;
			
			this.title = "Market Details";
			this.backButtonHandler = goBack;
			this.layout = myLayout;
			
			var backButton:Button = new Button();
			backButton.addEventListener(Event.TRIGGERED, goBack);
			backButton.styleNameList.add("back-button");
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			var menuIcon:ImageLoader = new ImageLoader();
			menuIcon.source = "assets/icons/menu.png";
			menuIcon.width = menuIcon.height = 25;
			
			var menuButton:Button = new Button();
			menuButton.addEventListener(Event.TRIGGERED, showCallout);
			menuButton.styleNameList.add("header-button");
			menuButton.defaultIcon = menuIcon;
			this.headerProperties.rightItems = new <DisplayObject>[menuButton];
			
			var marketLabel:Label = new Label();
			marketLabel.layoutData = new VerticalLayoutData(100, NaN);
			marketLabel.textRendererProperties.wordWrap = true;
			marketLabel.paddingTop = 15;
			marketLabel.paddingLeft = marketLabel.paddingRight = 10;
			marketLabel.text = "<b>" + _data.selectedFarm.MarketName + "</b>";
			this.addChild(marketLabel);
			
			var addressLabel:Label = new Label();
			addressLabel.layoutData = new VerticalLayoutData(100, NaN);
			addressLabel.textRendererProperties.wordWrap = true;
			addressLabel.paddingLeft = addressLabel.paddingRight = 10;
			addressLabel.text = _data.selectedFarm.street + "\n" + _data.selectedFarm.city + ", " + _data.selectedFarm.State + ", " + _data.selectedFarm.zip;
			this.addChild(addressLabel);
			
			if(_data.selectedFarm.Season1Date)
			{
				var dateTime:Label =  new Label();
				dateTime.layoutData = new VerticalLayoutData(100, NaN);
				dateTime.textRendererProperties.wordWrap = true;
				dateTime.paddingLeft = dateTime.paddingRight = 10;
				dateTime.text = "<b>Date and Time</b>\n" + _data.selectedFarm.Season1Date + "\n" + _data.selectedFarm.Season1Time;
				this.addChild(dateTime);
			}
			
			var layoutForHGroup:HorizontalLayout = new HorizontalLayout();
			layoutForHGroup.gap = 10;
			layoutForHGroup.padding = 10;
			
			var HGroup:LayoutGroup = new LayoutGroup();
			HGroup.layout = layoutForHGroup;
			HGroup.layoutData = new VerticalLayoutData(100, NaN);
			this.addChild(HGroup);
			
			var directionsButton:Button = new Button();
			directionsButton.height = 50;
			directionsButton.label = "Get Directions";
			directionsButton.layoutData = new HorizontalLayoutData(50, NaN);
			directionsButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_DIRECTIONS);
			});
			HGroup.addChild(directionsButton);
			
			var mapButton:Button = new Button();
			mapButton.height = 50;
			mapButton.label = "View in Map";
			mapButton.layoutData = new HorizontalLayoutData(50, NaN);
			mapButton.addEventListener(Event.TRIGGERED, function():void
			{
				dispatchEventWith(GO_MAP);
			});
			HGroup.addChild(mapButton);
			
			if(_data.selectedFarm.Website)
			{
				var websiteIcon:ImageLoader = new ImageLoader();
				websiteIcon.source = "assets/icons/link.png";
				websiteIcon.width = websiteIcon.height = 25;
				
				var websiteBtn:Button = new Button();
				websiteBtn.addEventListener(Event.TRIGGERED, openLink);
				websiteBtn.layoutData = new VerticalLayoutData(100, NaN);
				websiteBtn.styleNameList.add("media-button");
				websiteBtn.defaultIcon = websiteIcon;
				websiteBtn.label = "<u>" + _data.selectedFarm.Website + "</u>";
				this.addChild(websiteBtn);
			}
			
			if(_data.selectedFarm.Facebook)
			{
				var facebookIcon:ImageLoader = new ImageLoader();
				facebookIcon.source = "assets/icons/facebook.png";
				facebookIcon.width = facebookIcon.height = 25;
				
				var facebookBtn:Button = new Button();
				facebookBtn.addEventListener(Event.TRIGGERED, openLink);
				facebookBtn.layoutData = new VerticalLayoutData(100, NaN);
				facebookBtn.styleNameList.add("media-button");
				facebookBtn.defaultIcon = facebookIcon;
				facebookBtn.label = "<u>" + _data.selectedFarm.Facebook + "</u>";
				this.addChild(facebookBtn);
			}
			
			if(_data.selectedFarm.Twitter)
			{
				var twitterIcon:ImageLoader = new ImageLoader();
				twitterIcon.source = "assets/icons/twitter.png";
				twitterIcon.width = twitterIcon.height = 25;
				
				var twitterBtn:Button = new Button();
				twitterBtn.addEventListener(Event.TRIGGERED, openLink);
				twitterBtn.layoutData = new VerticalLayoutData(100, NaN);
				twitterBtn.styleNameList.add("media-button");
				twitterBtn.defaultIcon = twitterIcon;
				twitterBtn.label = "<u>" + _data.selectedFarm.Twitter + "</u>";
				this.addChild(twitterBtn);
			}
			
			if(_data.selectedFarm.Youtube)
			{
				var youtubeIcon:ImageLoader = new ImageLoader();
				youtubeIcon.source = "assets/icons/youtube.png";
				youtubeIcon.width = twitterIcon.height = 25;
				
				var youtubeBtn:Button = new Button();
				youtubeBtn.addEventListener(Event.TRIGGERED, openLink);
				youtubeBtn.layoutData = new VerticalLayoutData(100, NaN);
				youtubeBtn.styleNameList.add("media-button");
				youtubeBtn.defaultIcon = youtubeIcon;
				youtubeBtn.label = "<u>" + _data.selectedFarm.Youtube + "</u>";
				this.addChild(youtubeBtn);
			}
			
			if(_data.selectedFarm.OtherMedia)
			{
				var basketIcon:ImageLoader = new ImageLoader();
				basketIcon.source = "assets/icons/basket.png";
				basketIcon.width = basketIcon.height = 25;
				
				var basketBtn:Button = new Button();
				basketBtn.addEventListener(Event.TRIGGERED, openLink);
				basketBtn.layoutData = new VerticalLayoutData(100, NaN);
				basketBtn.styleNameList.add("media-button");
				basketBtn.defaultIcon = basketIcon;
				basketBtn.label = "<u>" + _data.selectedFarm.OtherMedia + "</u>";
				this.addChild(basketBtn);
			}
			
			var goodsLabel:Label = new Label();
			goodsLabel.layoutData = new VerticalLayoutData(100, NaN);
			goodsLabel.padding = 10;
			goodsLabel.text = "Available Goods";
			this.addChild(goodsLabel);
			
			var tiledLayout:TiledRowsLayout = new TiledRowsLayout();
			tiledLayout.horizontalGap = 15;
			tiledLayout.verticalGap = 20;
			
			var goodsGroup:LayoutGroup = new LayoutGroup();
			goodsGroup.layoutData = new VerticalLayoutData(100, NaN);
			goodsGroup.layout = tiledLayout;
			this.addChild(goodsGroup);
			
			var servicesLabel:Label = new Label();
			servicesLabel.layoutData = new VerticalLayoutData(100, NaN);
			servicesLabel.padding = 10;
			servicesLabel.text = "Payment Services";
			this.addChild(servicesLabel);
			
			var servicesGroup:LayoutGroup = new LayoutGroup();
			servicesGroup.layoutData = new VerticalLayoutData(100, NaN);
			servicesGroup.layout = tiledLayout;
			this.addChild(servicesGroup);
			
			var bottomSpacer:BasicButton = new BasicButton();
			bottomSpacer.height = 10;
			this.addChild(bottomSpacer);
			
			for (var item:String in _data.selectedFarm)
			{				
				if(_data.selectedFarm[item] == "Y"){
					
					if(item == "SNAP" || item == "WIC" || item == "SFMNP" || item == "Credit" || item == "WICcash"){
						servicesGroup.addChild(createService(item));
					} else {
						goodsGroup.addChild(createGood(item));
					}					
				}				
			}
			
			if(goodsGroup.numChildren == 0){
				goodsGroup.addChild(createNoInfoButton());
			}
			
			if(servicesGroup.numChildren == 0){
				servicesGroup.addChild(createNoInfoButton());
			}			
		}
		
		private function createNoInfoButton():Button
		{
			var icon:ImageLoader = new ImageLoader();
			icon.width = icon.height = 50;
			icon.source = "assets/icons/info.png";
			
			var button:Button = new Button();
			button.label = "No Info";
			button.styleNameList.add("home-button");
			button.defaultIcon = icon;
			return button;
		}
		
		private function createGood(name:String):Button
		{
			var icon:ImageLoader = new ImageLoader();
			icon.width = icon.height = 50;
			icon.source = "assets/goods/"+name+".png";
			
			var button:Button = new Button();
			button.styleNameList.add("home-button");
			button.defaultIcon = icon;
			
			if(name == "Bakedgoods"){
				button.label = "Baked Goods";
			} else if(name == "PetFood"){
				button.label = "Pet Food";
			} else if(name == "WildHarvested"){
				button.label = "W. Harvested";
			} else {
				button.label = name;				
			}
			
			return button;
		}
		
		private function createService(name:String):Button
		{
			var icon:ImageLoader = new ImageLoader();
			icon.width = icon.height = 50;
			icon.source = "assets/icons/check_circle.png";
			
			var button:Button = new Button();
			button.styleNameList.add("home-button");
			button.defaultIcon = icon;
			
			if(name == "WICcash"){
				button.label = "WIC CVV";
			} else {
				button.label = name;				
			}
			return button;
		}
		
		private function openLink(event:Event):void
		{			
			var url:String = Button(event.currentTarget).label;
			url = url.substr(3, url.length-7);

			navigateToURL(new URLRequest(url));
		}
		
		private function showCallout(event:Event):void
		{
			var button:Button = Button(event.currentTarget);
			var content:LayoutGroup = new LayoutGroup();
			content.layout = new VerticalLayout();
			
			if(_data.fromBookmarks == true){
				var deleteBookmarksButton:Button = new Button();
				deleteBookmarksButton.label = "Remove Bookmark";
				deleteBookmarksButton.styleNameList.add("callout-button");
				deleteBookmarksButton.addEventListener(Event.TRIGGERED, function():void
				{
					var bookmarksArray:Array = new Array();
					var file:File = File.applicationStorageDirectory.resolvePath("bookmarks.data");
					var fileStream:FileStream;
					
					fileStream = new FileStream();
					fileStream.open(file, FileMode.READ);
					bookmarksArray = fileStream.readObject();
					fileStream.close();
					
					bookmarksArray.removeAt(_data.selectedIndex);
					
					fileStream = new FileStream();
					fileStream.open(file, FileMode.WRITE);
					fileStream.writeObject(bookmarksArray);
					fileStream.close();
					
					callout.close();
					goBack();
				});				
				content.addChild(deleteBookmarksButton);
			} else {
				var addBookmarkButton:Button = new Button();
				addBookmarkButton.label = "Add to Bookmarks";
				addBookmarkButton.styleNameList.add("callout-button");
				addBookmarkButton.addEventListener(Event.TRIGGERED, function():void
				{
					var bookmarksArray:Array = new Array();	
					var file:File = File.applicationStorageDirectory.resolvePath("bookmarks.data");
					var fileStream:FileStream;
					
					if(file.exists)
					{
						fileStream = new FileStream();
						fileStream.open(file, FileMode.READ);
						bookmarksArray = fileStream.readObject();
						fileStream.close();
						
						if(checkIfBookmarkExists(bookmarksArray)){
							alert = Alert.show("Market already bookmarked.", "Error", new ListCollection([{label:"OK"}]));
						} else {
							bookmarksArray.push(_data.selectedFarm);
							
							fileStream = new FileStream();
							fileStream.open(file, FileMode.WRITE);
							fileStream.writeObject(bookmarksArray);
							fileStream.close();
							
							callout.close();	
						}						
					} else {
						bookmarksArray.push(_data.selectedFarm);
						
						fileStream = new FileStream();
						fileStream.open(file, FileMode.WRITE);
						fileStream.writeObject(bookmarksArray);
						fileStream.close();
						
						callout.close();
					}				
				});
				content.addChild(addBookmarkButton);
			}		
					
			var callout:Callout = Callout.show(content, button);
		}
		
		private function checkIfBookmarkExists(arr:Array):Boolean
		{
			var result:Boolean;
			
			for each(var item:Object in arr){
				if(item.FMID == _data.selectedFarm.FMID){
					result = true;
				} else 
					result = false;
			}			
			
			return result;
		}
		
		private function goBack():void
		{
			if(alert){
				alert.removeFromParent(true);
			}
			
			this.dispatchEventWith(Event.COMPLETE);
		}
	}
}