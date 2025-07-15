import { LightningElement, track, api } from 'lwc';
import result_found from '@salesforce/label/c.result_found';
import results_found from '@salesforce/label/c.results_found';
import noDataText from "@salesforce/label/c.noDataText";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import messagetext from '@salesforce/label/c.brs_public_search_limit_exceeded_message';
import messageheader from '@salesforce/label/c.Attention';
import getMarkSearchList from '@salesforce/apex/brs_TradeAndServiceSearchController.getMarkSearchList';
import getSelectedTradeAndServiceMarkDetails from '@salesforce/apex/brs_TradeAndServiceSearchController.getSelectedTradeAndServiceMarkDetails';
import getAllFilters from '@salesforce/apex/brs_genericSearchClass.getAllFilters';
import Trade_and_service_marks from '@salesforce/label/c.Trade_and_service_marks';
import Trade_Help_Text_Desc from '@salesforce/label/c.Trade_Help_Text_Desc';
import Trade_help_text_url from '@salesforce/label/c.Trade_help_text_url';
import help_head from '@salesforce/label/c.help_head';
import Trade_Service_Marks from '@salesforce/label/c.Trade_Service_Marks';
import Results_for_Label from '@salesforce/label/c.Results_for_Label';
import TN_Inquiry from '@salesforce/label/c.TN_Inquiry';
import active from '@salesforce/label/c.Active_Label';
import expired from '@salesforce/label/c.brs_BusFileStatusExpired';
import cancelled from '@salesforce/label/c.Cancelled_Label';

export default class Brs_tradeAndServiceMarksSearch extends LightningElement {
  @track isLoading = false;
  @track hasResults = false;
  @track selectedFilters = [];
  @track breadcrumbList = [TN_Inquiry, ""];
  @track isUserSearched = false;
  @track actuallength;
  @track hasOnlyOneResult = false;
  @track filtersArray = [];
  @track showTSDetails = false;
  @track allResults = [];
  @track allData = [];
  @track showResults = false;
  @track selectedTSDetails = {};
  @track searchString = "";
  @track searchResultLength;
  @track compName = "brs_tradeAndServiceMarksSearch";
  @track updatedData = [];
  @track scholerContent = `<span><p><b style="font-size: 18px;color: #808080;">${help_head}</b></p><p><br></p><p><span style="font-size: 14px;color: #333232;">${Trade_Help_Text_Desc}</span></p><br><a href="${Trade_help_text_url}" target="_blank">${Trade_help_text_url}</a></span>`;

  label = {
    result_found,
    results_found,
    noDataText,
    messagetext,
    messageheader,
    Trade_and_service_marks,
    Trade_Help_Text_Desc,
    Trade_help_text_url,
    help_head,
    Trade_Service_Marks,
    Results_for_Label,
    active,expired,cancelled
  }

  connectedCallback() {
    document.addEventListener('keydown', function () {
      document.documentElement.classList.remove('mouseFocus');
    });
    document.addEventListener('mousedown', function () {
      document.documentElement.classList.add('mouseFocus');
    });
    this.getFilters();
  }

  getFilters() {
    getAllFilters({ searchType: this.label.Trade_Service_Marks }).then((data) => {
      if (data) {
        data.forEach((filterOption) => {
          filterOption.src = assetFolder + "/icons/" + filterOption.filterIcon;
          filterOption.filterOptions.forEach((option) => {
            option.label = option.MasterLabel;
            option.value = option.picklistApiName;
          });
        });
        this.filtersArray = data;
      }
    }).catch((error) => {
      ComponentErrorLoging(
        this.compName,
        "getAllFilters",
        "",
        "",
        "Medium",
        error.message
      );
    });
  }

  onSearch(event) {
    this.searchString = event.detail.searchString;
    this.breadcrumbList[1] = `${this.label.Results_for_Label} "${this.searchString}"`;
    this.selectedFilters = [];
    this.getAllTSMarks([]);
  }

  getAllTSMarks(filters) {
    let searchObj = {
      searchString: this.searchString,
      isExportClicked: false
    }
    if (filters.length > 0) {
      searchObj = {
        ...searchObj,
        filterList: filters
      }
    } else {
      this.resetFilters();
    }
    this.isLoading = true;
    this.selectedTSDetails = {};
    this.showTSDetails = false;
    this.removeBreadCrumbLastItem();
    this.hasOnlyOneResult = false;
    getMarkSearchList(searchObj).then((data) => {
      this.isLoading = false;
      this.isUserSearched = true;
      let allResults = JSON.parse(JSON.stringify(data));
      this.actuallength = allResults.resultAllCount;
      this.allResults = {
        ...allResults,
        resultList: this.modifyTradeAndServiceData(allResults.resultList)
      }
      this.allData = this.allResults.resultList;
      this.hasResults = this.allResults.resultCount > 0;
      this.hasOnlyOneResult = this.allResults.resultCount === 1;
      this.searchResultLength = this.allResults.resultList.length;
      this.showResults = false;
      setTimeout(() => {
        this.showResults = true;
      }, 10);
    }).catch((error) => {
      this.isLoading = false;
      ComponentErrorLoging(
        this.compName,
        "getMarkSearchList",
        "",
        "",
        "Medium",
        error.message
      );
    });
  }

  modifyTradeAndServiceData(tAndS) {
    return tAndS.map((eachTrade) => {
      return {
        ...eachTrade,
        showDetails: false,
        fullAddress: this.getFullAddress(eachTrade),
        badgeClassName: eachTrade.status ? this.getChipClassName(eachTrade.status.toLowerCase()) : false
      }
    })
  }

  getFullAddress(trade) {
    let address = [];
    if (trade.ownerAddStreet) {
      address.push(trade.ownerAddStreet)
    }
    if (trade.ownerAddUnit) {
      address.push(trade.ownerAddUnit)
    }
    if (trade.ownerAddCity) {
      address.push(trade.ownerAddCity)
    }
    if (trade.ownerAddState) {
      address.push(trade.ownerAddState)
    }
    if (trade.ownerAddZipCode) {
      address.push(trade.ownerAddZipCode)
    }
    if (trade.ownerAddCountry) {
      address.push(trade.ownerAddCountry)
    }
    return address.join(", ");
  }

  getChipClassName(status) {
    let className = "";
    if (status == "active" || status == this.label.active) {
      className = "active"
    } else if (status == "expired" || status == this.label.expired || status == "cancelled" || status == this.label.cancelled){
      className = "inactive"
    } else {
      className = false;
    }
    return className;
  }

  onShowDetails(event) {
    const markId = event.detail;
    this.isLoading = true;
    getSelectedTradeAndServiceMarkDetails({ markId }).then((data) => {
      this.isLoading = false;
      if (data) {
        this.showTSDetails = true;
        this.hasResults = false;
        this.selectedTSDetails = {
          ...data,
          fullAddress: this.getFullAddress(data),
          badgeClassName: data.status ? this.getChipClassName(data.status.toLowerCase()) : false
        };
        this.removeBreadCrumbLastItem();
        this.breadcrumbList.push(data.ownerName);
      }
    }).catch((error) => {
      this.isLoading = false;
      ComponentErrorLoging(
        this.compName,
        "getSelectedTradeAndServiceMarkDetails",
        "",
        "",
        "Major",
        error.message
      );
    });
  }

  updatePaginatedData(event) {
    this.updatedData = event.detail;
  }

  removeBreadCrumbLastItem() {
    if (this.breadcrumbList.length > 2) {
      this.breadcrumbList.pop();
    }
  }

  onBreadCrumbClick(event) {
    if (this.showTSDetails) {
      const index = event.detail.index;
      if (index !== "2") {
        this.showTSDetails = false;
        this.hasResults = true;
        this.removeBreadCrumbLastItem();
      }
    }
  }

  handleFilterSelection(event) {
    const data = event.detail;
    const hasfilter = this.selectedFilters.filter((filter) => filter.type === data.type);
    if (this.selectedFilters.length > 0 && hasfilter.length > 0) {
      this.selectedFilters = this.selectedFilters.map((filter, index) => {
        if (filter.type === data.type) {
          return {
            ...filter,
            selectedOptions: data.selectedOptions
          }
        } else {
          return filter;
        }
      });
    } else {
      this.selectedFilters.push(data);
    }
    //Do not include filters which are deselected
    this.selectedFilters = this.selectedFilters.filter(filter => filter.selectedOptions.length > 0);
    this.updateFilters(data.selectedOptions, data.type);
    this.getAllTSMarks(this.selectedFilters);
  }

  updateFilters(selectedOptions, selectedFilterType) {
    const filterIndex = this.filtersArray.findIndex(element => {
      return element.apiName == selectedFilterType;
    });
    this.filtersArray[filterIndex].selectedOptions = selectedOptions;
    this.filtersArray[filterIndex].filterOptions.forEach(elm => {
      elm.isChecked = selectedOptions.includes(elm.value);
    });
  }

  resetFilters() {
    const filtersArray = this.filtersArray.map(filter => {
      return {
        ...filter,
        selectedOptions: null,
        filterOptions: filter.filterOptions.map((option) => {
          return {
            ...option,
            isChecked: false
          }
        })
      }
    });
    this.filtersArray = filtersArray;
  }

  onPrintPdfFile() {
    this.template.querySelector("c-brs_trade-and-service-mark-details").printPdf();
  }
}