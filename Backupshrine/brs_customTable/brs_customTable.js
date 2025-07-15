import { LightningElement, api } from 'lwc';
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";

export default class Brs_customTable extends LightningElement {
    @api tableData;
    @api tableColumns;
    labels = {
        businessProfile_show_less
    }
    
    connectedCallback() {
        this.setTableData();
    }

    setTableData() {
        this.tableData = this.tableData.map((column) => {
            const values = this.tableColumns.map((columnArray) => {
                const showmore = columnArray.type === "showmore";
                const showFormattedNumber = columnArray.type === 'showFormattedNumber';
                let length = 0;
                let initialValue = "";
                let fieldValue = column[columnArray.fieldName];
                if (showmore) {
                    if (column[columnArray.fieldName].length > 1) {
                        length = column[columnArray.fieldName].length - 1;
                    }
                    if (column[columnArray.fieldName].length > 0) {
                        initialValue = column[columnArray.fieldName][0];
                    }
                }
                if(columnArray.type==='currency' && fieldValue){
                    fieldValue = '$'+fieldValue;
                }
                return {
                    label: columnArray.label,
                    value: fieldValue,
                    showmore,
                    showall: false,
                    length,
                    showFormattedNumber,
                    initialValue
                }
            });
            return {
                ...column,
                values
            }
        })
    }


    onShowMore(event) {
        var childindex = Number(event.currentTarget.dataset.name);
        var parentindex = Number(event.currentTarget.dataset.id);
        this.tableData = this.tableData.map((eachRow, i) => {
            let modified = eachRow.values;
            if (parentindex === i) {
                modified = modified.map((eachColumn, j) => {
                    return {
                        ...eachColumn,
                        showall: j === childindex
                    }
                });
            }else{
                modified = modified.map((eachColumn, j) => {
                    return {
                        ...eachColumn,
                        showall: false
                    }
                }); 
            }
            return {
                ...eachRow,
                values:modified
            }
        });
    }

    onShowLess(event){
        var parentindex = Number(event.currentTarget.dataset.id);
        this.tableData = this.tableData.map((eachRow, i) => {
            let modified = eachRow.values;
            if (parentindex === i) {
                modified = modified.map((eachColumn, j) => {
                    return {
                        ...eachColumn,
                        showall: false
                    }
                });
            }
            return {
                ...eachRow,
                values:modified
            }
        });
    }
}