import {
    LightningElement,
    api
} from 'lwc';

export default class Brs_breadCrumb extends LightningElement {
    @api items = [];
    @api theme = "theme1";
    onBreadCrumbClick(event) {
        const name = event.currentTarget.dataset.name;
        const index = event.currentTarget.dataset.index;
        const breadcrumbClick = new CustomEvent("breadcrumbclick", {
            detail: {
                name,
                index
            }
        });
        this.dispatchEvent(breadcrumbClick);
    }
}