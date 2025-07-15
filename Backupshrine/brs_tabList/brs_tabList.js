import { LightningElement, api, track } from 'lwc';

export default class Brs_tabList extends LightningElement {
    @api tabList = [];
    @api tabHeader = "";
    @track showSubMenu = false;
    @track subMenuClassName = "hide";
    connectedCallback() {
        if (this.tabList.length > 0) {
            this.tabHeader = this.tabList[0].label;
        }
        this.modifyList();
    }

    modifyList() {
        this.tabList = this.tabList.map((eachItem, index) => {
            return {
                ...eachItem,
                className: index == 0 ? "active" : ""
            }
        })
    }

    showMenu() {
        this.showSubMenu = !this.showSubMenu;
        this.subMenuClassName = this.showSubMenu ? "show" : "hide";
    }

    onTabClick(event) {
        const index = event.currentTarget.dataset.name;
        const tabClick = new CustomEvent('tabclick', {
            detail: index
        });
        this.dispatchEvent(tabClick);
        this.showSubMenu = false;
        this.subMenuClassName = "hide";
        this.tabList = this.tabList.map((eachItem, i) => {
            return {
                ...eachItem,
                className: i == index ? "active" : ""
            }
        });
        this.tabHeader = this.tabList[index].label;
    }

    onEnter(event) {
        const charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.onTabClick(event);
        }
    }

    onHeaderEnter(event) {
        const charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.showMenu(event);
        }
    }
}