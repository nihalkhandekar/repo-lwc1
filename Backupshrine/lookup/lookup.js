import {
    LightningElement,
    api,
    track
} from 'lwc';


const VIEWPORT_HEIGHT_SMALL = 834;
const ARIA_CONTROLS = 'aria-controls';
const ARIA_LABELLEDBY = 'aria-labelledby';
const ARIA_DESCRIBEDBY = 'aria-describedby';
const ARIA_LABEL = 'aria-label';
const ARIA_ACTIVEDESCENDANT = 'aria-activedescendant';

export default class Lookup extends LightningElement {

    @api source = 'community';
    @api autocomplete = false;
    @api dropdownAlignment = 'left';
    @api inputIconName = 'down'
    @api inputIconPosition = 'right';
    @api label;
    @api inputText = '';
    @api hasActionButton = false;
    @api maxLength;
    @api originfield;
    @api usedFor = 'addressInput';

    @track _dropdownVisible = false;
    @track _hasDropdownOpened = false
    @track placeHolder;
    @track _highlightedOptionElement = null;
    @track _highlightedOptionElementId = null;
    @track _unprocessedItems = [];
    @track _items = [];
    @track _readonly = false;
    @track _selectableItems = [];
    @track selectedValue = '';
    @track _inputHasFocus = false;
    @track _disabled = false;
    @track hasFieldError;
    @track blurEvent;
    @track isZeroVisitFirst = true;
    isEnterHandlerAttached = false;
    @track listBoxId="listbox"

    typingTimer;
    doneTypingInterval = 2000;

    get autoflag() {
        if (this.autocomplete) {
            return ("On");
        } else {
            return ("Off")
        }

    }

    @api get placeholder() {
        return this.placeHolder;
    }

    set placeholder(val) {
        this.placeHolder = val;
    }
    
    _inputAriaControls;
    _activeElementDomId;

    connectedCallback() {
        this._connected = true;
        this.highlightDefaultItem();
        this._keyboardInterface = this.dropdownKeyboardInterface();
        var that = this;
        
        if (this._unprocessedItems && this._unprocessedItems.length !== 0) {
        
            if (!this.selectedValue) {
                this.selectedValue = this._unprocessedItems[0].value;

            }
        }
        document.addEventListener('click', function (event) {
            if (event.target) {
                if (event.target.closest('.cust-unique-class')) return;
            }
            that.closeDropdown();
        }, false);
    }

    disconnectedCallback() {
        this._connected = false;
        this._listBoxElementCache = undefined;
        document.removeEventListener('click', function (event) {});
    }

    @api get value() {
        return this.selectedValue;
    }

    get isCommunity() {
        return this.source === 'community';
    }

    set value(newValue) {
        if (newValue !== this.selectedValue && newValue != undefined) {
            this.selectedValue = newValue;
            setTimeout(()=>{
                let element = this.template.querySelector('input');
                
                if(element){
                    this.inputElement.value = newValue;
                    element.value = newValue;
                    
                }
            },500);
            
            if (this.connected && this._items) {
            }
        }
    }

    @api get disabled() {
        return this._disabled;
    }

    set disabled(value) {
        this._disabled = this.normalizeBoolean(value);

        if (this._disabled && this._dropdownVisible) {
            this.closeDropdown();
        }
    }

    @api get items() {
        return this._unprocessedItems;
    }

    set items(item = []) {
        this._unprocessedItems = item;
        if (this._connected) {
            if (this._hasDropdownOpened) {
                this.updateItems(item);

                if (this._dropdownVisible) {
                    if (this.isDropdownEmpty) {
                        this.closeDropdown();
                    } else {
                        this.highlightDefaultItem();
                    }
                }
            }

            if (this._shouldOpenDropDown) {
                this.openDropdownIfNotEmpty();
            }
        }

    }

    updateSelectedOptions() {
        this.markOptionSelectedFromValue(this.selectedValue);
    }

    markOptionSelectedFromValue(value) {
        if (this._items) {
            const selectedItem = this._items.find(item => item.value == value);
            if (this._selectedItem) {
                this._selectedItem.iconName = undefined;
                this._selectedItem.highlight = false;
            }
            this._selectedItem = selectedItem;
            if (selectedItem) {
                selectedItem.iconName = 'utility:check';
                this._selectedItem.highlight = true;
            }

            this._items = this._items.slice();
        }
    }

    updateItems(items) {
        if (!items) {
            return;
        }
        if (!Array.isArray(items)) {
            return "items must be an array";
        }
        this._selectableItems = 0;
        this._highlightedItemIndex = 0;
        this._items = items.map((i, index) => {
            this._selectableItems += 1;
            return {
                type: 'option-inline',
                text: i.label,
                highlight: this.value === i.value,
                value: i.value,
                selectable: true,
                index: this._selectableItems,
                id: this.itemId(index),
            };
        });
    }

    @api get readOnly() {
        return this._readonly;
    }

    set readOnly(value) {
        this._readonly = this.normalizeBoolean(value);
        if (this._readonly && this._dropdownVisible) {
            this.closeDropdown();
        }
    }

    @api get inputControlsElement() {
        return this._inputAriaControls;
    }

    set inputControlsElement(el) {
        this._inputAriaControls = el;
        this.synchronizeA11y();
    }

    @api get inputDescribedByElements() {
        return this._inputDescribedBy;
    }

    set inputDescribedByElements(elements) {
        if (Array.isArray(elements)) {
            this._inputDescribedBy = elements;
        } else {
            this._inputDescribedBy = [elements];
        }

        this.synchronizeA11y();
    }

    @api get inputLabelledByElement() {
        return this._inputLabelledBy;
    }

    set inputLabelledByElement(el) {
        this._inputLabelledBy = el;
        this.synchronizeA11y();
    }

    @api
    get hasError() {
        return this.hasFieldError;
    }

    set hasError(val) {
        var inputElem = this.template.querySelector("input.cust-lookup");
        this.hasFieldError = val;
        if (inputElem) {
            if (val) {

                inputElem.classList.add("error-class");
            } else {
                inputElem.classList.remove("error-class");
            }
        }

    }

    get _shouldOpenDropDown() {
        return (
            !this.dropdownDisabled &&
            this._inputHasFocus &&
            this._requestedDropdownOpen
        );
    }


    get isReadOnly() {
        return !this.autocomplete || this._disabled;
    }

    get inputIconContainerClass() {
        return this.inputIconPosition == 'left' ?
            'slds-input-has-icon slds-input-has-icon_left' :
            'slds-input-has-icon slds-input-has-icon_right';
    }

    get inputIconClass() {
        return this.inputIconPosition == 'left' ?
            'slds-icon_container slds-icon-utility-down slds-input__icon slds-input__icon_left' :
            'slds-icon_container slds-icon-utility-down slds-input__icon slds-input__icon_right';
    }

    get inputIcon() {
        if (this.isCommunity) {
            return `/CustomerOnlineServices/_slds/icons/utility-sprite/svg/symbols.svg#${this.inputIconName}`;
        }
        return `/_slds/icons/utility-sprite/svg/symbols.svg#${this.inputIconName}`;
    }

    get computedDropdownClass() {
        const alignment = this.dropdownAlignment;
        let dropdownLengthClass = '';
        if (this._dropdownVisible) {
            if (window.innerHeight <= VIEWPORT_HEIGHT_SMALL) {
                dropdownLengthClass = 'slds-dropdown_length-with-icon-7';
            } else {
                dropdownLengthClass = 'slds-dropdown_length-with-icon-10';
            }
        }

        return `slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ${dropdownLengthClass}`;
    }

    get inputElement() {
        return this.template.querySelector('input');
    }

    get dropdownDisabled() {
        return this.readOnly || this.disabled;
    }

    get computedInputValue() {
        return this.selectedValue;
    }

    get inputLabelledById() {
        return getRealDOMId(this._inputLabelledBy);
    }

    get inputAriaControlsId() {
        return getRealDOMId(this._inputAriaControls);
    }

    get inputId() {
        return this.getRealDOMId(this.template.querySelector('input'));
    }

    get computedAriaDescribedBy() {
        const ariaValues = [];
        this._inputDescribedBy.forEach(el => {
            ariaValues.push(getRealDOMId(el));
        });
        return normalizeAriaAttribute(ariaValues);
    }

    get openDropdown() {
        return (this._items.length !== 0);
    }

    get isDropdownEmpty() {
        return (Array.isArray(this._items) || this._items.length === 0);
    }

    get listboxElement() {
        if (!this._listBoxElementCache) {
            this._listBoxElementCache = this.template.querySelector(
                '[role="listbox"]'
            );
        }
        return this._listBoxElementCache;
    }

    get _inputReadOnly() {
        return this._readonly
    }


    handleListboxScroll(event) {
        event.stopPropagation();

        const listbox = event.target;
        const height = listbox.getBoundingClientRect().height;
        const maxScroll = listbox.scrollHeight - height;

        const buffer = 20;
        const bottomReached = listbox.scrollTop + buffer >= maxScroll;
        if (bottomReached) {
            this.dispatchEvent(new CustomEvent('endreached'))
        }

    }

    itemIndexFromId(id) {
        return parseInt(id.substring(id.lastIndexOf('-') + 1), 10);
    }

    getRealDOMId(el) {
        if (el && typeof el === 'string') {
            return el;
        } else if (el) {
            return el.getAttribute('id');
        }
        return null;
    }

    dropdownKeyboardInterface() {
        const that = this;
        return {
            getTotalOptions() {
                return that._selectableItems;
            },
            selectByIndex(index) {
                that.selectOptionAndCloseDropdown(
                    that.findOptionElementByIndex(index)
                );
            },
            highlightOptionWithIndex(index) {
                that.highlightOptionAndScrollIntoView(
                    that.findOptionElementByIndex(index)
                );
            },
            isInputReadOnly() {
                return that._inputReadOnly;
            },
            highlightOptionWithText(currentIndex, text) {
                for (
                    let index = currentIndex + 1; index < that._items.length; index++
                ) {
                    const option = that._items[index];
                    if (
                        option.selectable &&
                        option.text &&
                        option.text
                        .toLowerCase()
                        .indexOf(text.toLowerCase()) === 0
                    ) {
                        that.highlightOptionAndScrollIntoView(
                            that.findOptionElementByIndex(index)
                        );

                        return;
                    }
                }
                for (let index = 0; index < currentIndex; index++) {
                    const option = that._items[index];
                    if (
                        option.selectable &&
                        option.text &&
                        option.text
                        .toLowerCase()
                        .indexOf(text.toLowerCase()) === 0
                    ) {
                        that.highlightOptionAndScrollIntoView(
                            that.findOptionElementByIndex(index)
                        );

                        return;
                    }
                }
            },
            isDropdownVisible() {
                return that._dropdownVisible;
            },
            openDropdownIfNotEmpty() {
                that.openDropdownIfNotEmpty();
            },
            closeDropdown() {
                that.closeDropdown();
            }
        }
    }

    highlightDefaultItem() {
        this.removeHighlight();
        requestAnimationFrame(() => {
            this.highlightOptionAndScrollIntoView(
                this.findOptionElementByIndex(this._highlightedItemIndex)
            );
        });
    }

    removeHighlight() {
        const option = this._highlightedOptionElement;
        if (option) {
            option.classList.toggle('slds-has-focus', false);
            this._highlightedOptionElement = null;
            this._highlightedOptionElementId = null;
            this._activeElementDomId = null;
        }
        if(this.usedFor === 'domicileAddressSelection'){
            let element = this.querySelector('li[data-type="address-action"]');
            if(element){
                element.classList.remove('slds-has-focus');
            }
        }
    }

    highlightOption(option) {
        this.removeHighlight();
        if (option) {
            this._highlightedOptionElement = option;
            this._highlightedOptionElementId = option.getAttribute(
                'data-item-id'
            );
            option.classList.toggle('slds-has-focus');
            this._activeElementDomId = option.id;
        }
    }

    getCurrentHighlightedOptionIndex() {
        if (
            this._highlightedOptionElementId &&
            this._highlightedOptionElementId.length > 0
        ) {
            return this.itemIndexFromId(this._highlightedOptionElementId);
        }
        return -1;
    }

    highlightOptionAndScrollIntoView(optionElement) {
        if (this._selectableItems.length === 0 || !optionElement) {
            return;
        }
        this.highlightOption(optionElement);
        scrollIntoViewIfNeeded(optionElement, this.listboxElement);
    }

    findOptionElementByIndex(index) {
        return this.template.querySelector(
            `[data-item-id="${this.itemId(index)}"]`
        );
    }

    synchronizeA11y() {
        const input = this.template.querySelector('input');
        if (!input) {
            return;
        }
        synchronizeAttrs(input, {
            [ARIA_LABELLEDBY]: this.inputLabelledById,
            [ARIA_DESCRIBEDBY]: this.computedAriaDescribedBy,
            [ARIA_ACTIVEDESCENDANT]: this._activeElementDomId,
            [ARIA_CONTROLS]: this.computedInputControls,
            [ARIA_LABEL]: this.inputLabel
        });
    }

    itemId(index) {
        return this.inputId + '-' + index;
    }

    closeDropdown() {
        this._dropdownVisible = false;
        this._hasDropdownOpened = false;
    }

    handleFormSubmit(event) {
        event.preventDefault();
    }

    handleFocus(event) {
        this._inputHasFocus = true;
    }

    handleInputSelect(event) {
        event.stopPropagation();
    }

    handleTextChange(event) {
        this.openDropdownIfNotEmpty();
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: event.target.value.trim(),
                    type: 'textchange'   
                }
            })
        );
    }

    handleClick(event) {
        if (this.dropdownDisabled) {
            return;
        } else {
            this.openDropdownIfNotEmpty();
        }
    }

    handleTriggerClick(event) {
        event.stopPropagation();
        this.allowBlur();
        if (this.dropdownDisabled) {
            return;
        }
        if (this._inputReadOnly) {
            if (this._dropdownVisible) {
                this.closeDropdown();
            } else {
                this.openDropdownIfNotEmpty();
            }
        } else {
            this.openDropdownIfNotEmpty();
        }
        this.inputElement.focus();
    }

    closePopup() {
        this.closeDropdown();
    }

    handleInput(event) {
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                value: event.target.value,
                type: 'input'
            }
        }));
    }

    handleInputKeyPress(event) {
        if (event.target.value) {
            this.dispatchEvent(new CustomEvent('textkeypress', {
                detail: {
                    value: this.inputElement.value,
                    type: 'keypress'
                }
            }));
        }
    }

    doneTyping(event){ 
        this.dispatchEvent(new CustomEvent('donetyping', {
            detail: {
                value: this.inputElement.value,
                type: 'keypress'
            }
        }));
    }

    handleInputKeyup(event) {
        clearTimeout(this.typingTimer);
        if(event.target.value){
        }
        this.selectedValue = event.target.value.trim();
        this.dispatchEvent(
            new CustomEvent('keyup', {
                composed: true,
                bubbles: true,
                detail: {
                    value: event.target.value.trim(),
                    type: 'keyup'
                }
            })
        );

        if (this._keyboardInterface.isDropdownVisible()) {
            this.openDropdownIfNotEmpty();
        }
    }

    handleInputKeyDown(event) {
        if (this.dropdownDisabled) {
            return;
        } else {
            if (this._keyboardInterface.isDropdownVisible()) {
                this.openDropdownIfNotEmpty();
            }
            let currentIndex = this.getCurrentHighlightedOptionIndex();
            if (event.key === 'Up' || event.key === 'ArrowDown' || event.key === 'Down' || event.key === 'ArrowUp') {
                const isUpKey = event.key === 'Up' || event.key === 'ArrowUp';
                let nextIndex;
                if (currentIndex >= 0) {
                    if(currentIndex === 0 && this.isZeroVisitFirst && this.usedFor === 'domicileAddressSelection'){
                        this.highlightAddButton();
                        return;
                    }
                    nextIndex = isUpKey ? currentIndex - 1 : currentIndex + 1;
                    if (nextIndex >= this._keyboardInterface.getTotalOptions()) {
                        nextIndex = 0;
                        this.isZeroVisitFirst = true;
                    } else if (nextIndex < 0) {
                        nextIndex = this._keyboardInterface.getTotalOptions() - 1;
                    }
                } else {
                    nextIndex = isUpKey ? this._keyboardInterface.getTotalOptions() - 1 : 0;
                }

                if (this._keyboardInterface.getTotalOptions() > 0) {
                    this._keyboardInterface.highlightOptionWithIndex(nextIndex);
                }
            }

            if (event.key === 'Enter') {
                if (this._keyboardInterface.isDropdownVisible() && currentIndex >= 0) {
                    this._keyboardInterface.selectByIndex(currentIndex);
                } else {
                    this._keyboardInterface.openDropdownIfNotEmpty();
                }
            }
        }
    }

    highlightAddButton(){
        let element = this.querySelector('li[data-type="address-action"]');
        let anchorEl = this.querySelector('li[data-type="address-action"] a');
        if(element){
            const option = this._highlightedOptionElement;
            if (option) {
                option.classList.toggle('slds-has-focus', false);
            }
            element.classList.add('slds-has-focus');
            element.focus();
            anchorEl.focus();
            if(anchorEl){
                anchorEl.addEventListener('keydown',(e)=>{
                    let keyCode = e.keyCode || e.which;
                    e.preventDefault();
                    if(keyCode === 13){
                        anchorEl.click();
                    }
                });
            }
            this.isZeroVisitFirst = false;
        }
    }

    handleBlur(event) {
        this.blurEvent = {
            "source": event.target.dataset.source,
            "value": event.target.value.trim()
        }
        setTimeout(() => {
            var blurEvent = this.blurEvent;
            if (blurEvent) {

                var source = blurEvent.source;
                if (source === "street") {
                    var streetElem = this.template.querySelector("[data-source='street']");
                    var fieldvalue = streetElem.value;
                    this.dispatchEvent(new CustomEvent('blurstreetlookup', {
                        composed: true,
                        bubbles: true,
                        detail: {
                            value: fieldvalue,
                            source: source
                        }
                    }));
                    this._inputHasFocus = false;
                    if (this._cancelBlur) {
                        return;
                    }
                    this.closeDropdown();
                } else if (source === "city") {
                    var cityElem = this.template.querySelector("[data-source='city']");
                    if (cityElem) {
                        var fieldvalue = cityElem.value.toUpperCase();
                    }
                    var isCityCorrect = false;
                    if (fieldvalue && fieldvalue !== "") {
                        for (let i = 0; i < this._items.length; i++) {
                            if (fieldvalue === this._items[i].value.toUpperCase()) {
                                isCityCorrect = true;
                                break;
                            }
                        }
                    }
                    if (!isCityCorrect) {
                        fieldvalue = "";
                    }
                    this.dispatchEvent(new CustomEvent('blurcitylookup', {
                        composed: true,
                        bubbles: true,
                        detail: {
                            value: fieldvalue,
                            cityFlag: isCityCorrect
                        }
                    }));

                    this._inputHasFocus = false;
                    if (this._cancelBlur) {
                        return;
                    }
                    this.closeDropdown();
                }
            }
        }, 700);
    }



    allowBlur() {
        this._cancelBlur = false;
    }

    cancelBlur() {
        this._cancelBlur = true;
    }

    handleOptionClick(event) {
        this.cancelBlur();
        event.stopPropagation();
        event.preventDefault();
        this.selectOptionAndCloseDropdown(event.currentTarget);
    }

    selectOptionAndCloseDropdown(optionElement) {
        this.closeDropdown();
        this.inputElement.focus();
        const value = optionElement.getAttribute('data-value');
        
        this.dispatchEvent(
            new CustomEvent('select', {
                composed: true,
                bubbles: true,
                detail: {
                    value,
                    type: 'select'
                }
            })
        );
        this._requestedDropdownOpen = false;
    }

    openDropdownIfNotEmpty() {
        if (this._dropdownVisible) {
            return;
        }

        if (!this._hasDropdownOpened) {
            if (this._unprocessedItems) {
                this.updateItems(this._unprocessedItems);
            }
                this._hasDropdownOpened = true;
                let dropWrapper = this.template.querySelector(".cust-dropdown");
                if (!this.isEnterHandlerAttached) {
                    this.isEnterHandlerAttached = true;
                    dropWrapper.addEventListener("keyup", function enterEventHandler(event) {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            if (this.querySelector(".slds-listbox__item.slds-has-focus")) {
                                this.querySelector(".slds-listbox__item.slds-has-focus").click();
                            }
                        }
                    })
                }
        }

        if (this.isDropdownEmpty) {
            this._requestedDropdownOpen = true;
            return;
        }

        if (this._items && this._items.length) {
            this._dropdownVisible = true;
            this._hasDropdownOpened = true;
        }
        this._requestedDropdownOpen = false;
        this._dropdownVisible = true;
        this.highlightDefaultItem();
        this.dispatchEvent(new CustomEvent('dropdownopen'));
    }

    normalizeBoolean(value) {
        return typeof value === 'string' || !!value;
    }
}

function scrollIntoViewIfNeeded(element, scrollingParent) {
    const parentRect = scrollingParent.getBoundingClientRect();
    const findMeRect = element.getBoundingClientRect();
    if (findMeRect.top < parentRect.top) {
        if (element.offsetTop + findMeRect.height < parentRect.height) {
            scrollingParent.scrollTop = 0;
        } else {
            scrollingParent.scrollTop = element.offsetTop;
        }
    } else if (findMeRect.bottom > parentRect.bottom) {
        scrollingParent.scrollTop += findMeRect.bottom - parentRect.bottom;
    }
}

function normalizeAriaAttribute(value) {
    let arias = Array.isArray(value) ? value : [value];
    arias = arias
        .map(ariaValue => {
            if (typeof ariaValue === 'string') {
                return ariaValue.replace(/\s+/g, ' ').trim();
            }
            return '';
        })
        .filter(ariaValue => !!ariaValue);

    return arias.length > 0 ? arias.join(' ') : null;
}