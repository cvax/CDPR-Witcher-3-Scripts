class W3GuiPlayerInventoryComponent extends W3GuiBaseInventoryComponent
{
	private var _shopInvCmp:W3GuiShopInventoryComponent;
	private var _filterType : EInventoryFilterType;
	default _filterType = IFT_Weapons;
	private var _currentItemCategoryType : name;
	default _currentItemCategoryType = '';
	
	public var bPaperdoll : bool;
	default bPaperdoll = false;	

	public var currentDefaultItemAction : EInventoryActionType;
	default currentDefaultItemAction = IAT_None;
	
	public var ignorePosition : bool;
	default ignorePosition = false;
	
	public var filterTagList : array<name>;
		
	protected function InvalidateItems( items : array<SItemUniqueId> ) 
	{
	}
	
	public function SetShopInvCmp(targetShopInvCmp:W3GuiShopInventoryComponent):void
	{
		_shopInvCmp = targetShopInvCmp;
	}
	
	public function SetFilterType( filterType : EInventoryFilterType )
	{
		_filterType = filterType;
	}	

	public function GetFilterType() : EInventoryFilterType
	{
		return _filterType;
	}	

	public function SetItemCategoryType( cat : name )
	{
		_currentItemCategoryType = cat;
	}
	
	// TBD: Generalize across different inventory components and move into base class
	public function SwapItems( gridItem : SItemUniqueId, paperdollItem : SItemUniqueId )
	{
		var invalidatedItems : array< SItemUniqueId >;
		var uiDataPaperdoll : SInventoryItemUIData;
		var uiDataGrid : SInventoryItemUIData;
		var mountToHand, result : bool;
		
		uiDataGrid = _inv.GetInventoryItemUIData( gridItem );
		uiDataPaperdoll = _inv.GetInventoryItemUIData( paperdollItem );
		
		uiDataPaperdoll.gridPosition = uiDataGrid.gridPosition;
		uiDataGrid.gridPosition = -1;
		
		_inv.SetInventoryItemUIData( paperdollItem, uiDataPaperdoll );
		_inv.SetInventoryItemUIData( gridItem, uiDataGrid );
		
		mountToHand = _inv.IsItemHeld( paperdollItem );
		result = GetWitcherPlayer().UnequipItem(paperdollItem);
		if(result)
			result = GetWitcherPlayer().EquipItem(gridItem, EES_Quickslot1, mountToHand);		//provide custom quickslot 1-4 or leave like that (if 1 and occupied, will put to next free)
		//TODO #B
		//handle results == false in both cases above?
		
		invalidatedItems.PushBack( gridItem );
		invalidatedItems.PushBack( paperdollItem );
		InvalidateItems( invalidatedItems );
	}	
	
	public function EquipItem( item : SItemUniqueId, slot : int)
	{
		var invalidatedItems : array< SItemUniqueId >;
				
		GetWitcherPlayer().EquipItem(item, slot);
		
		thePlayer.SetUpdateQuickSlotItems(true);
		invalidatedItems.PushBack( item );
		InvalidateItems( invalidatedItems );
	}	
	
	public function EquipItemInGivenSlot( item : SItemUniqueId, slot : int)
	{
		var invalidatedItems : array< SItemUniqueId >;
				
		GetWitcherPlayer().EquipItemInGivenSlot(item, slot, false);
		
		thePlayer.SetUpdateQuickSlotItems(true);
		invalidatedItems.PushBack( item );
		InvalidateItems( invalidatedItems );
	}	
	
	public function UnequipItem( item : SItemUniqueId )
	{
		var invalidatedItems : array<SItemUniqueId>;
	
		GetWitcherPlayer().UnequipItem(item);
		invalidatedItems.PushBack( item );
		InvalidateItems( invalidatedItems );
	}
	
	public function DropItem( item : SItemUniqueId, quantity : int )
	{	
		GetWitcherPlayer().DropItem(item, quantity);
		super.DropItem( item, quantity );
	}
	
	//FIXME
	//#B check this - right now the only upgrades we can use are oils - changed thePlayer.UpgradeItem to thePlayer.ApplyOil
	public function UpgradeItem( item : SItemUniqueId, upgrade : SItemUniqueId )
	{
		var invalidatedItems : array< SItemUniqueId >;
		
		GetWitcherPlayer().ApplyOil(upgrade, item );
		//if(UpgradeItem)
		//{
			_inv.RemoveItem( upgrade, 1 );
			//_dpPaperdoll.bUpgradeTooltip = false; //#B deprecated
			invalidatedItems.PushBack( item );
			invalidatedItems.PushBack( upgrade );
			InvalidateItems( invalidatedItems );
		//}
	}
	
	public function ConsumeItem( item : SItemUniqueId )
	{
		var invalidatedItems : array< SItemUniqueId >;
		var itemCategory : name;
		
		itemCategory = _inv.GetItemCategory( item );
		
		thePlayer.ConsumeItem( item ); // Also removes the item
		invalidatedItems.PushBack( item );
		InvalidateItems( invalidatedItems );
	}	
	
	public function MoveItem( item : SItemUniqueId, moveToIndex : int )
	{
		var invalidatedItems : array< SItemUniqueId >;
		var uiDataGrid : SInventoryItemUIData;
		
		uiDataGrid = _inv.GetInventoryItemUIData( item );
		
		uiDataGrid.gridPosition = moveToIndex;
		
		_inv.SetInventoryItemUIData( item, uiDataGrid );
		
		invalidatedItems.PushBack( item );
		InvalidateItems( invalidatedItems );
	}

	public function MoveItems( item : SItemUniqueId, moveToIndex : int, itemSecond : SItemUniqueId, moveSecondToIndex : int )
	{
		var invalidatedItems : array< SItemUniqueId >;
		var uiDataGrid : SInventoryItemUIData;
		var uiDataGridSecond : SInventoryItemUIData;
		
		uiDataGrid = _inv.GetInventoryItemUIData( item );
		uiDataGridSecond = _inv.GetInventoryItemUIData( itemSecond );
		
		uiDataGrid.gridPosition = moveToIndex;
		uiDataGridSecond.gridPosition = moveSecondToIndex;
		
		_inv.SetInventoryItemUIData( item, uiDataGrid );
		_inv.SetInventoryItemUIData( itemSecond, uiDataGridSecond );
		
		invalidatedItems.PushBack( item );
		invalidatedItems.PushBack( itemSecond );
		InvalidateItems( invalidatedItems );
	}
	
	public function CleanupItemsGridPosition() : void
	{
		var i, len : int;
		var curItemId   : SItemUniqueId;
		var itemsList   : array< SItemUniqueId >;
		var currentUiData : SInventoryItemUIData;
		
		_inv.GetAllItems( itemsList );
		
		len = itemsList.Size();
		for ( i = 0; i < len; i += 1 )
		{
			curItemId = itemsList[i];
			currentUiData = _inv.GetInventoryItemUIData( curItemId );
			currentUiData.gridPosition = -1;
			_inv.SetInventoryItemUIData(curItemId, currentUiData);
		}
	}
	
	public function ReadBook( item : SItemUniqueId )
	{
		//LogChannel('Inventory_Books',"gPIC ReadBook ");
		_inv.ReadBook( item );
		//_dpPlayer.InvalidateData(); // #B deprecated
		//@TODO update item read state, update this item
	}
	
	public function IsBookRead( item : SItemUniqueId ) : bool
	{
		//LogChannel('Inventory_Books',"gPIC IsBookRead ");
		return _inv.IsBookRead( item );
	}
	
	public function UpdateTooltip(item : SItemUniqueId, secondItem : SItemUniqueId)
	{
	}
	
	public function GetItemName(item : SItemUniqueId):name
	{
		return _inv.GetItemName(item);
	}
	
	public function GetCraftedItemInfo(craftedItemName:name, targetObject:CScriptedFlashObject) : void
	{
		var playerInv			: CInventoryComponent;
		var wplayer		        : W3PlayerWitcher;
		var dm 					: CDefinitionsManagerAccessor;
		var htmlNewline			: string;
		var minQuality 			: int;
		var maxQuality 			: int;
		var color				: string;
		var itemType 			: EInventoryFilterType;
		var minWeightAttribute 	: SAbilityAttributeValue;
		var maxWeightAttribute 	: SAbilityAttributeValue;
		var i					: int;
		var attributes			: array<SAttributeTooltip>;
		
		var itemName			: string;
		var itemDesc			: string;
		var rarity				: string;
		var rarityId			: int;
		var type				: string;
		var weightValue			: float;
		var weight				: string;
		var enhancementSlots 	: int;
		var attributesStr		: string;
		var tmpStr				: string;
		
		var requiredLevel		: string;
		var primaryStatDiff     : string;
		var primaryStatLabel    : string;
		var primaryStatValue    : float;
		var primaryStatDiffValue: float;
		var primaryStatDiffStr  : string;
		var eqPrimaryStatLabel  : string;
		var eqPrimaryStatValue  : float;
		var primaryStatName	    : name;
		var itemCategory		: name;
		var dontCompare			: bool;
		var itemSlot 			: EEquipmentSlots;
		var equipedItemId		: SItemUniqueId;
		var equipedItemStats	: array<SAttributeTooltip>;
		var attributesList      : CScriptedFlashArray;
		var addDescription		: string;
		
		htmlNewline = "&#10;";
		
		wplayer = GetWitcherPlayer();
		dm = theGame.GetDefinitionsManager();
		_inv.GetItemStatsFromName(craftedItemName, attributes);
		_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
		itemType = dm.GetFilterTypeByItem(craftedItemName);
		
		itemCategory = dm.GetItemCategory(craftedItemName);
		
		dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);
		weightValue = minWeightAttribute.valueBase;
		
		if ( itemCategory == 'usable' || itemCategory == 'upgrade' || itemCategory == 'junk' )
		{
			weightValue = 0.01 + weightValue * 0.2;
		}
		else if ( dm.ItemHasTag(craftedItemName, 'CraftingIngredient'))
		{
			weightValue = 0.0;
		}
		else
		{
			weightValue = 0.01 + weightValue * 0.5;
		}
		
		tmpStr = FloatToStringPrec( weightValue, 2 );
		weight = GetLocStringByKeyExt("attribute_name_weight") + ": " + tmpStr;
		
		itemName = GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(craftedItemName));
		itemDesc = GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName));
		
		rarityId = minQuality;
		rarity = GetItemRarityDescriptionFromInt(minQuality);
		type = GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
		
		enhancementSlots = dm.GetItemEnhancementSlotCount( craftedItemName );		

		
		itemSlot = GetSlotForItemByCategory(itemCategory);
		wplayer.GetItemEquippedOnSlot(itemSlot, equipedItemId);
		playerInv = thePlayer.GetInventory();
		
		eqPrimaryStatValue = 0;
		if (playerInv.IsIdValid(equipedItemId))
		{
			playerInv.GetItemStats(equipedItemId, equipedItemStats);
			playerInv.GetItemPrimaryStat(equipedItemId, eqPrimaryStatLabel, eqPrimaryStatValue);
		}
		
		dontCompare = itemCategory == 'potion' || itemCategory == 'petard' || itemCategory == 'oil';
		playerInv.GetItemPrimaryStatFromName(craftedItemName, primaryStatLabel, primaryStatValue, primaryStatName);
		
		primaryStatDiff = "none";
		primaryStatDiffValue = 0;
		primaryStatDiffStr = "";
		
		if ( !dontCompare )
		{
			primaryStatDiff = GetStatDiff(primaryStatValue, eqPrimaryStatValue);
			primaryStatDiffValue = RoundMath(primaryStatValue) - RoundMath(eqPrimaryStatValue);
			if (primaryStatDiffValue > 0)
			{
				primaryStatDiffStr = "<font color=\"#19D900\"> +" + NoTrailZeros(primaryStatDiffValue) + "</font>";
			}
			else if (primaryStatDiffValue < 0)
			{
				primaryStatDiffStr = "<font color=\"#E00000\"> " + NoTrailZeros(primaryStatDiffValue) + "</font>";
			}
			
			if (dm.IsItemWeapon(craftedItemName))
			{
				targetObject.SetMemberFlashNumber("PrimaryStatDelta", .1);
			}
			else
			{
				targetObject.SetMemberFlashNumber("PrimaryStatDelta", 0);
			}
		}
		
		if ( dm.IsItemAnyArmor(craftedItemName) || dm.IsItemBolt(craftedItemName) || dm.IsItemWeapon(craftedItemName) )
		{
			requiredLevel = _inv.GetItemLevelColor( theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + " " + theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) + "</font>";
			targetObject.SetMemberFlashString("requiredLevel", requiredLevel);
		}
		
		attributesList = targetObject.CreateFlashArray();		
		CalculateStatsComparance(attributes, equipedItemStats, targetObject, attributesList, true,  dontCompare);
		
		attributesStr = "";
		for (i = 0; i < attributes.Size(); i += 1)
		{
			// #J using temp string to follow since finalString gets so big
			color = attributes[i].attributeColor;
			attributesStr += "<font color=\"#" + color + "\">";
			attributesStr += attributes[i].attributeName + ": ";
			if( attributes[i].percentageValue )
			{
				attributesStr += RoundMath( attributes[i].value * 100 ) + " %";
			}
			else
			{
				attributesStr += RoundMath( attributes[i].value );
			}
			attributesStr += "</font>" + htmlNewline;
		}

		addDescription = "";
		if (maxQuality > 1 && maxQuality < 4) // #J Relics and sets dont have random Attributes from what I understand
		{
			addDescription += "<font color=\"#AAFFFC\">" + (minQuality - 1) + " - " + (maxQuality - 1) + " " + GetLocStringByKeyExt("panel_crafting_number_random_attributes") + "</font>";
		}
		
		targetObject.SetMemberFlashString("additionalDescription", addDescription);
		targetObject.SetMemberFlashString("itemName", itemName);
		targetObject.SetMemberFlashString("itemDescription", itemDesc);
		targetObject.SetMemberFlashString("rarity", rarity);
		targetObject.SetMemberFlashInt("rarityId", rarityId);
		targetObject.SetMemberFlashString("type", type);
		targetObject.SetMemberFlashInt("enhancementSlots", enhancementSlots );
		targetObject.SetMemberFlashString("weight", weight);
		targetObject.SetMemberFlashString("attributes", attributesStr);
		targetObject.SetMemberFlashArray("attributesList", attributesList);
		targetObject.SetMemberFlashString("PrimaryStatLabel", primaryStatLabel);
		targetObject.SetMemberFlashNumber("PrimaryStatValue", primaryStatValue);
		targetObject.SetMemberFlashString("PrimaryStatDiff", primaryStatDiff);
		targetObject.SetMemberFlashString("PrimaryStatDiffStr", primaryStatDiffStr);
	}
	
	//--------------------------------------------------------------------------------------------------------
	//									DATA
	
	protected function isEquipped( item : SItemUniqueId ) : bool
	{
		return GetWitcherPlayer().IsItemEquipped(item);
	}
	
	protected function getQuickslotId( item : SItemUniqueId ) : int
	{
		return (int)GetWitcherPlayer().GetItemSlot(item);
	}	
	
	public /*override*/ function SetInventoryFlashObjectForItem( itemId : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var equipped 			  : int;
		var slotType 			  : EEquipmentSlots;
		var itemCategory		  : name;
		var itemName			  : name;
		var invItem 			  : SInventoryItem;
		var itemCost			  : int;
		var itemNotForSale	      : bool;
		var isDefaultBolt		  : bool;
		var canDrop				  : bool;
		var dropBlockedByTutorial : bool;
		
		super.SetInventoryFlashObjectForItem( itemId, flashObject );
		
		isDefaultBolt = _inv.IsItemBolt(itemId) && _inv.ItemHasTag(itemId, theGame.params.TAG_INFINITE_AMMO);
		
		itemName = _inv.GetItemName(itemId);
		// TBD: Getting slotType in superclass too...
		slotType = GetItemEquippedSlot( itemId );
		equipped = (int)GetWitcherPlayer().GetItemSlot( itemId );
		
		flashObject.SetMemberFlashInt( "equipped", equipped );
		flashObject.SetMemberFlashBool( "cantUnequip", isDefaultBolt );
		itemCategory = _inv.GetItemCategory( itemId );
		
		if (_shopInvCmp)
		{
			invItem = GetInventoryComponent().GetItem( itemId );
			itemCost = _shopInvCmp.GetInventoryComponent().GetInventoryItemPriceModified( invItem, true );
			
			if ( itemCost <= 0  || _inv.ItemHasTag(itemId,'Quest'))
			{
				itemNotForSale = true;
			}
			canDrop = false;
		}
		else
		{
			//Tutorial hack - in forced alchemy tutorial we cook Thunderbolt 1 potion and we have to make sure you cannot drop it.
			//It's a general item so it cannot have NoDrop or Quest tags and there is no way to dynamically add/remove tags from items.
			dropBlockedByTutorial = FactsQuerySum("tut_forced_preparation") > 0 && _inv.GetItemName(itemId) == 'Thunderbolt 1';
			canDrop = !_inv.ItemHasTag(itemId, 'NoDrop') && !_inv.ItemHasTag(itemId,'Quest') && !dropBlockedByTutorial && !isDefaultBolt;
		}
		
		if (ignorePosition)
		{
			flashObject.SetMemberFlashInt( "gridPosition", -1 );
		}
		
		flashObject.SetMemberFlashBool( "canDrop", canDrop );
		flashObject.SetMemberFlashBool( "disableAction", itemNotForSale );
	}
	
	function GetOnlyMiscItems( out items : array<SItemUniqueId> ) : void
	{
		var tempItems : array<SItemUniqueId>;
		var tempItemsToRemove : array<SItemUniqueId>;
		var i : int;
		_inv.GetAllItems(tempItems);
		tempItemsToRemove = _inv.GetItemsByTag( 'AlchemyIngridient' );
		for( i = 0; i < tempItemsToRemove.Size(); i += 1 )
		{
			tempItems.Remove(tempItemsToRemove[i]);
		}
		LogChannel('MISC_ITEMS',"tempItems - alchemy size "+tempItems.Size());
		tempItemsToRemove = _inv.GetItemsByTag( 'CraftingIngridient' );
		for( i = 0; i < tempItemsToRemove.Size(); i += 1 )
		{
			tempItems.Remove(tempItemsToRemove[i]);
		}
		LogChannel('MISC_ITEMS',"tempItems - crafting size "+tempItems.Size());	
		tempItemsToRemove = _inv.GetItemsByTag( 'Quest' );
		for( i = 0; i < tempItemsToRemove.Size(); i += 1 )
		{
			tempItems.Remove(tempItemsToRemove[i]);
		}
		LogChannel('MISC_ITEMS',"tempItems - quests size "+tempItems.Size());	

		LogChannel('MISC_ITEMS',"tempItems - crafting size "+tempItems.Size());	
		tempItemsToRemove = _inv.GetAllWeapons();
		for( i = 0; i < tempItemsToRemove.Size(); i += 1 )
		{
			tempItems.Remove(tempItemsToRemove[i]);
		}
		LogChannel('MISC_ITEMS',"tempItems - wepons size "+tempItems.Size());
		
		for( i = tempItems.Size()-1; i > -1; i -= 1 )
		{
			if(_inv.IsItemAnyArmor(tempItems[i]))
			{
				tempItems.Erase(i);
			}
		}
		LogChannel('MISC_ITEMS',"tempItems - armors size "+tempItems.Size());
		items = tempItems;
	}
	
	
	// Player	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var itemCategory : name;
		var itemName : name;
		
		if( bPaperdoll )//@FIXME BIDON - temp hack
		{
			return super.ShouldShowItem( item );
		}
		
		if ( ! super.ShouldShowItem( item ) )
		{
			return false;
		}
		
		if ( ! filterByTagsList( item ) )
		{
			return false;
		}
		
		if ( _filterType != IFT_QuestItems && _inv.ItemHasTag( item, 'Quest' ) && !isHorseItem(item) ) // #B tricky ... we want to show quest items only in quest tab ? even they have usefull category ?
		{
			return false;
		}
		itemName = _inv.GetItemName(item);
		itemCategory = _inv.GetItemCategory( item );
		if ( itemCategory == 'schematic' ) //#B schematics should be shown ?
		{
			return false;
		}
		
		/*if( theGame.IsPadConnected() )
		{
			return CheckShowItemByCategory( item, itemCategory );
		}
		else
		{*/
			if ( isEquipped( item ) )
			{
				return false; 
			}
			return CheckIfShouldShowItem( item );
		//}
	}
	
	private function filterByTagsList( item : SItemUniqueId ):bool
	{
		var i, len:int;
		len = filterTagList.Size();
		for (i = 0; i < len; i+=1)
		{
			if (!_inv.ItemHasTag(item, filterTagList[i]))
			{
				return false;
			}
		}
		return true;
	}
	
	private function CheckShowItemByCategory( item : SItemUniqueId, itemCategory : name ) : bool // #B deprecated
	{
		var itemName : name;
		
		itemName = _inv.GetItemName(item);
	
		if( _filterType != IFT_Default )
		{
			return CheckIfShouldShowItem( item );
		}
		else
		{
			if( _inv.GetSlotForItemId(item) != EES_InvalidSlot && _currentItemCategoryType != '' )
			{
				if( _inv.IsItemQuickslotItem(item) )
				{
					switch( _currentItemCategoryType )
					{
						case 'quick1':
						case 'quick2':
						/*case 'quick3':
						case 'quick4':
						case 'quick5':*/
							return true;
					}
				}
				else if( itemCategory == _currentItemCategoryType )
				{
					return true;
				}
				else if( _inv.IsItemSteelSwordUsableByPlayer(item) && _currentItemCategoryType == 'steel' )
				{
					return true;
				}
				else if( _inv.IsItemSilverSwordUsableByPlayer(item) && _currentItemCategoryType == 'silver' )
				{
					return true;
				}
			}
			else if( _inv.GetSlotForItemId(item) == EES_InvalidSlot && _currentItemCategoryType == '' )
			{
				return CheckIfShouldShowItem( item );
			}
		}
		return false;
	}
	
	private function CheckIfShouldShowItem( item : SItemUniqueId ) : bool
	{
		var shouldShow : bool;
		
		shouldShow = false;
		switch( _filterType )
		{
			case IFT_Default:
				shouldShow = !isItemReadable(item) && !isFoodItem(item) && ! isIngredientItem( item ) && ! isQuestItem( item ) && !isWeaponItem( item ) && ! isArmorItem( item ) && ! isAlchemyItem( item ) && !isUpgradeItem( item ) && !isItemSchematic( item ) && !isToolItem(item) && !isHorseItem( item );
				break;
			case IFT_QuestItems:
				shouldShow = isQuestItem( item ) && !isHorseItem( item );
				break;
			case IFT_Ingredients:
				shouldShow = isIngredientItem( item );
				break;
			case IFT_Weapons:
				shouldShow = isWeaponItem( item ) || isArmorItem( item ) || isUpgradeItem( item ) || isHorseItem( item ) || isToolItem(item);
				break;
			case IFT_Books:
				shouldShow = !isQuestItem( item ) && isItemReadable( item );
				break;
			case IFT_AlchemyItems:
				shouldShow = isAlchemyItem( item ) || isFoodItem(item) ;
				break;
			case IFT_AllExceptHorseItem:
				shouldShow = !isHorseItem( item );
				break;
			case IFT_None:
				shouldShow = true;
				break;
			default:
				break;		
		}
			
		return shouldShow;
	}	
		
	protected function HAXIsMiscItem( item : SItemUniqueId ) : bool // #@TODO BIDON find and kill
	{
		return ! _inv.ItemHasTag( item, 'CraftingIngredient' ) && ! isQuestItem( item ) && _inv.GetSlotForItemId(item) == EES_InvalidSlot;
	}
	
	/*private function isAlchemyItem( item : SItemUniqueId ) : bool
	{
		return _inv.ItemHasTag( item, 'AlchemyIngredient' ) || _inv.ItemHasTag( item, 'Potion' );
	}
	
	private function isCraftingItem( item : SItemUniqueId ) : bool
	{
		return HAXIsMiscItem(item); // _inv.ItemHasTag( item, 'CraftingIngredient' )
	}*/
	
	protected function GetItems( out items : array<SItemUniqueId> )
	{
		//FIXME:
		// Not much of a useful switch at the moment...
		switch ( _filterType )
		{
			case IFT_Default:
			case IFT_Weapons:
			case IFT_Armors:
			case IFT_Ingredients:
			case IFT_AlchemyItems:
			case IFT_Books:
				_inv.GetAllItems( items );
				break;
			case IFT_QuestItems:
				items = _inv.GetItemsByTag( 'Quest' );
				break;
			default:
				break;
		}
	}
	
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool ) : EInventoryActionType
	{
		if( !bGetDefault && currentDefaultItemAction != IAT_None )
		{
			return currentDefaultItemAction;
		}
		else
		{
			return super.GetItemActionType( item );
		}
	}
}

function GetItemRarityDescriptionFromInt( quality : int ) : string
{
	switch(quality)
	{
		case 1:													  
			return "<font color='#7b7877'>"+GetLocStringByKeyExt("panel_inventory_item_rarity_type_common")+"</font>";
		case 2:
			return "<font color='#3661dc'>"+GetLocStringByKeyExt("panel_inventory_item_rarity_type_masterwork")+"</font>";
		case 3:
			return "<font color='#959500'>"+GetLocStringByKeyExt("panel_inventory_item_rarity_type_magic")+"</font>";
		case 4:
			return "<font color='#934913'>"+GetLocStringByKeyExt("panel_inventory_item_rarity_type_relic")+"</font>";	
		case 5:
			return "<font color='#197319'>"+GetLocStringByKeyExt("panel_inventory_item_rarity_type_set")+"</font>";
		default:
			return "";
	}
}
