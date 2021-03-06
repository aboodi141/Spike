package ui.screens.display.settings.chart
{
	import com.adobe.utils.StringUtil;
	
	import database.CGMBlueToothDevice;
	import database.CommonSettings;
	
	import feathers.controls.Check;
	import feathers.controls.PickerList;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.popups.DropDownPopUpContentManager;
	import feathers.data.ArrayCollection;
	import feathers.themes.BaseMaterialDeepGreyAmberMobileTheme;
	
	import model.ModelLocator;
	
	import starling.events.Event;
	
	import ui.screens.display.LayoutFactory;
	import ui.screens.display.SpikeList;
	
	import utils.Constants;
	import utils.DeviceInfo;
	
	[ResourceBundle("globaltranslations")]
	[ResourceBundle("chartsettingsscreen")]

	public class GlucoseDistributionSettingsList extends SpikeList 
	{
		/* Display Objects */
		private var enableGlucoseDistribution:ToggleSwitch;
		private var percentageRangePicker:PickerList;
		private var avgRangePicker:PickerList;
		private var a1cRangePicker:PickerList;
		private var a1cIFCCCheck:Check;
		private var displayInLandscapeCheck:Check;
		
		/* Properties */
		public var needsSave:Boolean = false;
		private var pieChartEnabledValue:Boolean;
		private var percentageRangeValue:Number;
		private var a1cRangeValue:Number;
		private var avgRangeValue:Number;
		private var isA1CIFCC:Boolean;
		private var displayInLandscapeValue:Boolean;
		
		public function GlucoseDistributionSettingsList()
		{
			super(true);
			
			setupProperties();
			setupInitialState();	
			setupContent();
		}
		
		/**
		 * Functionality
		 */
		private function setupProperties():void
		{
			/* Set Properties */
			clipContent = false;
			isSelectable = false;
			autoHideBackground = true;
			hasElasticEdges = false;
			paddingBottom = 5;
			width = Constants.stageWidth - (2 * BaseMaterialDeepGreyAmberMobileTheme.defaultPanelPadding);
		}
		
		private function setupInitialState():void
		{
			//Retrieve data from database
			pieChartEnabledValue = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_DISPLAY_GLUCOSE_DISTRIBUTION) == "true";
			percentageRangeValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_RANGES_OFFSET));
			a1cRangeValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_OFFSET));
			avgRangeValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_AVG_OFFSET));
			isA1CIFCC = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_IFCC_ON) == "true";
			displayInLandscapeValue = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SHOW_PIE_IN_LANDSCAPE) == "true";
		}
		
		private function setupContent():void
		{
			/* Controls */
			enableGlucoseDistribution = LayoutFactory.createToggleSwitch(pieChartEnabledValue);
			enableGlucoseDistribution.pivotX = 5;
			enableGlucoseDistribution.addEventListener(Event.CHANGE, onEnableGlucoseDistributionChanged);
			
			var rangesLabels:Array = ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','glucose_distribution_range_labels').split(",");
			var rangesValues:Array = "86400000,172800000,259200000,604800000,1209600000,2419200000,7257600000".split(",");
			var i:int;
			var value:Number;
			
			percentageRangePicker = LayoutFactory.createPickerList();
			percentageRangePicker.dataProvider = new ArrayCollection();
			for (i = 0; i < rangesLabels.length; i++) 
			{
				value = Number(StringUtil.trim(rangesValues[i]));
				percentageRangePicker.dataProvider.push( { label: StringUtil.trim(rangesLabels[i]), value: value } );
				if (value == percentageRangeValue)
					percentageRangePicker.selectedIndex = i;
			}
			percentageRangePicker.labelField = "label";
			percentageRangePicker.popUpContentManager = new DropDownPopUpContentManager();
			percentageRangePicker.addEventListener(Event.CHANGE, onSettingsChanged);
			
			avgRangePicker = LayoutFactory.createPickerList();
			avgRangePicker.dataProvider = new ArrayCollection();
			for (i = 0; i < rangesLabels.length; i++) 
			{
				value = Number(StringUtil.trim(rangesValues[i]));
				avgRangePicker.dataProvider.push( { label: StringUtil.trim(rangesLabels[i]), value: value } );
				if (value == avgRangeValue)
					avgRangePicker.selectedIndex = i;
			}
			avgRangePicker.labelField = "label";
			avgRangePicker.popUpContentManager = new DropDownPopUpContentManager();
			avgRangePicker.addEventListener(Event.CHANGE, onSettingsChanged);
			
			a1cRangePicker = LayoutFactory.createPickerList();
			a1cRangePicker.dataProvider = new ArrayCollection();
			for (i = 0; i < rangesLabels.length; i++) 
			{
				value = Number(StringUtil.trim(rangesValues[i]));
				a1cRangePicker.dataProvider.push( { label: rangesLabels[i], value: value } );
				if (value == a1cRangeValue)
					a1cRangePicker.selectedIndex = i;
			}
			a1cRangePicker.labelField = "label";
			a1cRangePicker.popUpContentManager = new DropDownPopUpContentManager();
			a1cRangePicker.addEventListener(Event.CHANGE, onSettingsChanged);
			
			a1cIFCCCheck = LayoutFactory.createCheckMark(isA1CIFCC);
			a1cIFCCCheck.addEventListener(Event.CHANGE, onSettingsChanged);
			
			displayInLandscapeCheck = LayoutFactory.createCheckMark(displayInLandscapeValue);
			displayInLandscapeCheck.addEventListener(Event.CHANGE, onSettingsChanged);
			
			refreshContent();
		}
		
		private function refreshContent():void
		{
			var data:Array = [];
			data.push( { label: ModelLocator.resourceManagerInstance.getString('globaltranslations','enabled_label'), accessory: enableGlucoseDistribution } );
			if (pieChartEnabledValue)
			{
				if (DeviceInfo.isTablet())
					data.push( { label: ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','display_in_landscape_label'), accessory: displayInLandscapeCheck } );
				if (!CGMBlueToothDevice.isFollower())
				{
					data.push( { label: ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','thresholds_range_label'), accessory: percentageRangePicker } );
					data.push( { label: ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','average_glucose_range_label'), accessory: avgRangePicker } );
					data.push( { label: ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','a1c_range_label'), accessory: a1cRangePicker } );
				}
				data.push( { label: ModelLocator.resourceManagerInstance.getString('chartsettingsscreen','a1c_ifcc_label'), accessory: a1cIFCCCheck } );
			}
			
			dataProvider = new ArrayCollection( data );
		}
		
		public function save():void
		{
			//Update Database
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_DISPLAY_GLUCOSE_DISTRIBUTION) != String(pieChartEnabledValue))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_CHART_DISPLAY_GLUCOSE_DISTRIBUTION, String(pieChartEnabledValue));
			
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_OFFSET) != String(a1cRangeValue))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_OFFSET, String(a1cRangeValue));
			
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_AVG_OFFSET) != String(avgRangeValue))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_AVG_OFFSET, String(avgRangeValue));
			
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_RANGES_OFFSET) != String(percentageRangeValue))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_RANGES_OFFSET, String(percentageRangeValue));
			
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_IFCC_ON) != String(isA1CIFCC))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_PIE_CHART_A1C_IFCC_ON, String(isA1CIFCC));
			
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SHOW_PIE_IN_LANDSCAPE) != String(displayInLandscapeValue))
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_SHOW_PIE_IN_LANDSCAPE, String(displayInLandscapeValue));
			
			needsSave = false;
		}
		
		/**
		 * Event Listeners
		 */
		private function onEnableGlucoseDistributionChanged(e:Event):void
		{
			//Update internal variables
			pieChartEnabledValue = enableGlucoseDistribution.isSelected
			needsSave = true;
			refreshContent();
		}
		
		private function onSettingsChanged(e:Event):void
		{
			percentageRangeValue = Number(percentageRangePicker.selectedItem.value);
			a1cRangeValue = Number(a1cRangePicker.selectedItem.value);
			avgRangeValue = Number(avgRangePicker.selectedItem.value);
			isA1CIFCC = a1cIFCCCheck.isSelected;
			displayInLandscapeValue = displayInLandscapeCheck.isSelected;
			
			needsSave = true;
		}
		
		/**
		 * Utility
		 */
		override public function dispose():void
		{
			if (enableGlucoseDistribution != null)
			{
				enableGlucoseDistribution.removeEventListener(Event.CHANGE, onEnableGlucoseDistributionChanged);
				enableGlucoseDistribution.dispose();
				enableGlucoseDistribution = null;
			}
			
			if (a1cRangePicker != null)
			{
				a1cRangePicker.removeEventListener(Event.CHANGE, onSettingsChanged);
				a1cRangePicker.dispose();
				a1cRangePicker = null;
			}
			
			if (avgRangePicker != null)
			{
				avgRangePicker.removeEventListener(Event.CHANGE, onSettingsChanged);
				avgRangePicker.dispose();
				avgRangePicker = null;
			}
			
			if (percentageRangePicker != null)
			{
				percentageRangePicker.removeEventListener(Event.CHANGE, onSettingsChanged);
				percentageRangePicker.dispose();
				percentageRangePicker = null;
			}
			
			if (a1cIFCCCheck != null)
			{
				a1cIFCCCheck.removeEventListener(Event.CHANGE, onSettingsChanged);
				a1cIFCCCheck.dispose();
				a1cIFCCCheck = null;
			}
			
			if (displayInLandscapeCheck != null)
			{
				displayInLandscapeCheck.removeEventListener(Event.CHANGE, onSettingsChanged);
				displayInLandscapeCheck.dispose();
				displayInLandscapeCheck = null;
			}
			
			super.dispose();
		}
	}
}