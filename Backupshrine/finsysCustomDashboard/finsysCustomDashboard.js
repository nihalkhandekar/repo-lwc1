import { LightningElement, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartJs from '@salesforce/resourceUrl/chartJS'; 
import chartJsDataLabels from '@salesforce/resourceUrl/chartJSDataLabel';
import resizeObserverPolyfill from '@salesforce/resourceUrl/resizeObserverOfChartJs';
import getTransactionData from '@salesforce/apex/TransactionChartController.getTransactionData';
import calculateTotalFees from '@salesforce/apex/TransactionChartController.calculateTotalFees';
import getOpenBatchCount from '@salesforce/apex/TransactionChartController.getOpenBatchCount';
import getClosedBatchCount from '@salesforce/apex/TransactionChartController.getClosedBatchCount';
import finsysCustomDashboard from '@salesforce/resourceUrl/finsysCustomDashboard'; 
import getBatchData from '@salesforce/apex/TransactionChartController.getBatchData';


export default class FinsysCustomDashboard extends LightningElement {

    @track totalDeposited = '$0.00';
    openBatches = '0';
    closedBatches = '0';

    @track showLineChartFilterModal = false;
    @track showBarChartFilterModal = false;
    @track showFilterModal = false;
    @track filterStartDate;
    @track filterEndDate;
    @track batchFilterStartDate;
    @track batchFilterEndDate;
    @track selectedBatchCodeForGraph;

    @track chart;
    @track barChart;
    @track lineChart;
    @track batchData = [];
    @track chartData = [];
    @track newData = [];
    @track isChartJsInitialized = false;
    @track scriptsLoaded = false;

    @track assignedTo;
    @track tier;
    @track outliner;
    @track stage;
    comulativeStartDate;
    comulativeEndDate;
    openBatchStartDate;
    openBatchEndDate;
    closedBatchStartDate;
    closedBatchEndDate;
    selectedOpenBatchCode;
    selectedClosedBatchCode;
    cssLoaded = false; 

    aasignedOptions = [];
    tierOptions = [];
    outlinerOptions = [];
    stageOptions = [];

    @track batchCodeOptions = [
        { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
        { label: 'Board of Accountancy', value: 'Board of Accountancy' },
        { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
        { label: 'Notary Public', value: 'Notary Public' },
        { label: 'Sales', value: 'Sales' },
        { label: 'Trademarks', value: 'Trademarks' }
      ];

    connectedCallback() {
        this.setDefaultDates();
    }

    setDefaultDates() {
        const today = new Date();
        const pastDate = new Date();
        pastDate.setDate(today.getDate() - 10); 
    
        // Manually format to MM/DD/YYYY
        const formatDate = (date) => {
            if (isNaN(date.getTime())) {
                console.error('Invalid Date:', date);
                return null;
            }
            let mm = String(date.getMonth() + 1).padStart(2, '0'); // Ensure 2-digit month
            let dd = String(date.getDate()).padStart(2, '0'); // Ensure 2-digit day
            let yyyy = date.getFullYear();
            return `${mm}/${dd}/${yyyy}`;
        };
    
        this.filterStartDate = formatDate(pastDate);
        this.filterEndDate = formatDate(today);
        this.batchFilterStartDate = formatDate(pastDate);
        this.batchFilterEndDate = formatDate(today);
        this.selectedBatchCodeForGraph = 'Authentication/Apostille';
    
        console.log('Start Date:', this.filterStartDate);
        console.log('End Date:', this.filterEndDate);
        console.log('Batch start Date:', this.batchFilterStartDate);
        console.log('Batch end Date:', this.batchFilterEndDate);
    }
    
    
    

    @wire(getTransactionData, { filterStartDate: '$filterStartDate', filterEndDate: '$filterEndDate' })
    wiredTransactionData({ error, data }) {
        if (data) {
            console.log('Transaction Data received:', data);
            this.chartData = data;
            if (this.scriptsLoaded) {
                this.initializeCharts();
            }
        } else if (error) {
            console.error('Error fetching transaction data:', error);
        }
    }

    @wire(getBatchData, { 
        batchFilterStartDate: '$batchFilterStartDate', 
        batchFilterEndDate: '$batchFilterEndDate',
        selectedBatchCode: '$selectedBatchCodeForGraph'
    })
    wiredBatchData({ error, data }) {
        if (data) {
            console.log('Batch Data received:', JSON.stringify(data));
            this.batchData = data;
            if (this.scriptsLoaded) {
                this.initializeBarChart();
            }
        } else if (error) {
            console.error('Error fetching batch data:', error);
        }
    }


    handleComulativeStartDateChange(event) {
        this.comulativeStartDate = event.target.value;
        this.updateTotalFees();
    }

    handleComulativeEndDateChange(event) {
        this.comulativeEndDate = event.target.value;
        this.updateTotalFees();
    }

    handleOpenBatchStartDateChange(event) {
        this.openBatchStartDate = event.target.value;
        this.handleFetchOpenBatches();
    }

    handleOpenBatchEndDateChange(event) {
        this.openBatchEndDate = event.target.value;
        this.handleFetchOpenBatches();
    }

    handleClosedBatchStartDateChange(event) {
        this.closedBatchStartDate = event.target.value;
        this.handleFetchClosedBatches();
    }

    handleClosedBatchEndDateChange(event) {
        this.closedBatchEndDate = event.target.value;
        this.handleFetchClosedBatches();
    }

    handleOpenBatchCodeChange(event){
        this.selectedOpenBatchCode = event.target.value;
        console.log('@@@', this.selectedOpenBatchCode);
        this.handleFetchOpenBatches();
    }

    handleClosedBatchCodeChange(event){
        this.selectedClosedBatchCode = event.target.value;
        console.log('@@@@@@@@@@@', this.selectedClosedBatchCode);
        this.handleFetchClosedBatches();  
    }

    updateTotalFees() {
        if (this.comulativeStartDate && this.comulativeEndDate) {
            calculateTotalFees({ comulativeStartDate: this.comulativeStartDate, comulativeEndDate: this.comulativeEndDate })
                .then(result => {
                    this.totalDeposited = new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD'
                    }).format(result);
                })
                .catch(error => {
                    console.error('Error calculating total fees:', error);
                    this.totalDeposited = '$0.00';
                });
        }
    }

    handleFetchOpenBatches() {
        if (this.openBatchStartDate && this.openBatchEndDate && this.selectedOpenBatchCode) {
            getOpenBatchCount({ 
                openBatchStartDate: this.openBatchStartDate, 
                openBatchEndDate: this.openBatchEndDate,
                selectedOpenBatchCode: this.selectedOpenBatchCode 
            })
            .then(result => {
                this.openBatches = result;
            })
            .catch(error => {
                console.error('Error fetching open batch count:', error);
            });
        }
    }

    handleFetchClosedBatches() {
        if (this.closedBatchStartDate && this.closedBatchEndDate && this.selectedClosedBatchCode) {
            getClosedBatchCount({ 
                closedBatchStartDate: this.closedBatchStartDate, 
                closedBatchEndDate: this.closedBatchEndDate,
                selectedClosedBatchCode: this.selectedClosedBatchCode 
            })
            .then(result => {
                this.closedBatches = result;
            })
            .catch(error => {
                console.error('Error fetching open batch count:', error);
            });
        }
    }

    handleBatchCodeGraphChange(event) {
        this.selectedBatchCodeForGraph = event.target.value;
        if (this.scriptsLoaded && this.batchData.length > 0) {
            this.initializeBarChart();
        }
    }
    


    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        this.isChartJsInitialized = true;
    
        // Load ResizeObserver polyfill first
        loadScript(this, resizeObserverPolyfill)
            .then(() => {
                console.log('ResizeObserver polyfill loaded');
                // Now load Chart.js
                return loadScript(this, chartJs);
            })
            .then(() => {
                console.log('Chart.js loaded successfully');
                // Now load ChartDataLabels
                return loadScript(this, chartJsDataLabels);
            })
            .then(() => {
                console.log('ChartDataLabels loaded successfully');
                if (window.Chart && window.ChartDataLabels) {
                    console.log("window assigned");
                    window.Chart.register(window.ChartDataLabels);
                    this.scriptsLoaded = true;
    
                    // Initialize charts only if chart data is available
                    if (this.chartData.length > 0) {
                        this.initializeCharts();
                    }
                    if (this.batchData.length > 0) {
                        this.initializeBarChart();
                    }    
                } else {
                    console.log("Could not attach Chart.js plugins");
                }
            })
            .catch((error) => {
                console.error('Error loading scripts:', error);
                this.isChartJsInitialized = false; // Reset flag to allow retry
            });

        // Load CSS separately
        if (!this.cssLoaded) {
            loadStyle(this, finsysCustomDashboard)
                .then(() => {
                    console.log('CSS loaded successfully');
                    this.cssLoaded = true;
                })
                .catch(error => {
                    console.error('Error loading CSS:', error);
                });
        }
    }

    initializeCharts() {
        try {
            // Sort data by date
            const sortedData = [...this.chartData].sort((a, b) => 
                new Date(a.trxnDate) - new Date(b.trxnDate)
            );

            const labels = sortedData.map(data => data.trxnDate);
            const amounts = sortedData.map(data => data.amount);

            this.initializeLineChart(labels, amounts);
        } catch (error) {
            console.error('Error initializing charts:', error);
        }
    }

    initializeLineChart(labels, amounts) {
        const lineCanvas = this.template.querySelectorAll('canvas')[0];
        const lineCtx = lineCanvas.getContext('2d');

        const lineData = {
            labels: labels,
            datasets: [{
                label: 'Transaction Amount',
                data: amounts,
                fill: false,
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgb(75, 192, 192)',
                tension: 0.4,
                pointRadius: 6,
                pointHoverRadius: 8,
                pointBackgroundColor: 'rgb(75, 192, 192)',
                pointBorderColor: 'white',
                pointBorderWidth: 2,
                borderWidth: 3
            }]
        };

        const lineConfig = {
            type: 'line',
            data: lineData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    datalabels: {
                        color: 'black',
                        font: {
                            weight: 'bold',
                            size: 11
                        },
                        formatter: (value) => {
                            return '$' + value.toFixed(2);
                        },
                        anchor: 'end',
                        align: 'top',
                        offset: 10
                    },
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            drawBorder: false,
                            color: 'rgba(0, 0, 0, 0.1)'
                        },
                        ticks: {
                            callback: (value) => '$' + value.toFixed(2)
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            },
            plugins: [window.ChartDataLabels]
        };

        if (this.lineChart) {
            this.lineChart.destroy();
        }
        this.lineChart = new Chart(lineCtx, lineConfig);
    }

    initializeBarChart() {
        const barCanvas = this.template.querySelectorAll('canvas')[1];
        const barCtx = barCanvas.getContext('2d');
    
        // Filter out dates with no batches
        const nonEmptyDates = [...new Set(this.batchData
            .filter(item => {
                // Check if there's at least one status with a non-zero amount for this date
                return item.totalAmount > 0;
            })
            .map(item => item.batchDate))]
            .sort((a, b) => new Date(a) - new Date(b)); // Sort dates chronologically
    
        // Only proceed if we have dates with data
        if (nonEmptyDates.length === 0) {
            // Clear the existing chart if no data
            if (this.barChart) {
                this.barChart.destroy();
            }
            return;
        }
    
        // Prepare data by status
        const statusData = {
            'Open': [],
            'Closed': [],
            'Sealed': []
        };
    
        nonEmptyDates.forEach(date => {
            const batchesForDate = this.batchData.filter(item => item.batchDate === date);
            
            Object.keys(statusData).forEach(status => {
                const amount = batchesForDate
                    .filter(item => item.status === status)
                    .reduce((sum, item) => sum + item.totalAmount, 0);
                statusData[status].push(amount);
            });
        });
    
        // Remove any status that has no data across all dates
        const datasets = Object.entries(statusData)
            .filter(([_, data]) => data.some(amount => amount > 0))
            .map(([status, data]) => ({
                label: status,
                data: data,
                backgroundColor: status === 'Open' ? 'rgba(75, 192, 192, 0.8)' : // Teal
                               status === 'Closed' ? 'rgba(255, 159, 64, 0.8)' : // Orange
                               'rgba(153, 102, 255, 0.8)', // Purple for Sealed
                stack: 'Stack 0'
            }));
    
        const barData = {
            labels: nonEmptyDates,
            datasets: datasets
        };
    
        const barConfig = {
            type: 'bar',
            data: barData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    datalabels: {
                        color: 'black',
                        font: {
                            weight: 'bold',
                            size: 11
                        },
                        formatter: (value) => {
                            return value > 0 ? '$' + value.toFixed(2) : '';
                        },
                        anchor: 'end',
                        align: 'top'
                    },
                    legend: {
                        position: 'bottom',
                        align: 'start',
                        labels: {
                            usePointStyle: true
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        stacked: true,
                        grid: {
                            drawBorder: false,
                            color: 'rgba(0, 0, 0, 0.1)'
                        },
                        ticks: {
                            callback: (value) => '$' + value.toFixed(2)
                        }
                    },
                    x: {
                        stacked: true,
                        grid: {
                            display: false
                        }
                    }
                }
            },
            plugins: [window.ChartDataLabels]
        };
    
        if (this.barChart) {
            this.barChart.destroy();
        }
        this.barChart = new Chart(barCtx, barConfig);
    }

    handleBarClick(event) {
        const activeElements = this.barChart.getElementsAtEventForMode(event, 'nearest', { intersect: true });
        if (activeElements.length > 0) {
            const firstPoint = activeElements[0];
            const datasetIndex = firstPoint.datasetIndex;
            const index = firstPoint.index;

            // Reset all background and border styles
            this.barChart.data.datasets[datasetIndex].backgroundColor = Array(this.barChart.data.labels.length)
                .fill('rgba(75, 192, 192, 0.8)');
            this.barChart.data.datasets[datasetIndex].borderColor = Array(this.barChart.data.labels.length).fill('');
            this.barChart.data.datasets[datasetIndex].borderWidth = Array(this.barChart.data.labels.length).fill(0);

            // Highlight selected bar
            this.barChart.data.datasets[datasetIndex].backgroundColor[index] = 'rgba(230, 153, 0, 0.5)';
            this.barChart.data.datasets[datasetIndex].borderColor[index] = 'orange';
            this.barChart.data.datasets[datasetIndex].borderWidth[index] = 4;

            this.barChart.update();
        }
    }

    handleLineChartFilterClick() {
        this.showLineChartFilterModal = !this.showLineChartFilterModal;
        this.showBarChartFilterModal = false; 
    }
    
    handleBarChartFilterClick() {
        this.showBarChartFilterModal = !this.showBarChartFilterModal;
        this.showLineChartFilterModal = false; 
    }    

    handleDateSelection(event) {
        const { startDate, endDate } = event.detail;
        if (this.activeChart === 'line') {
            this.filterStartDate = startDate;
            this.filterEndDate = endDate;
        } else if (this.activeChart === 'bar') {
            this.batchFilterStartDate = startDate;
            this.batchFilterEndDate = endDate;        
        }
        this.showFilterModal = false;
    }
    handleLineChartDateSelection(event) {
        // Handle line chart date selection
        this.showLineChartFilterModal = false;
        const { startDate, endDate } = event.detail;
        this.filterStartDate = startDate;
        this.filterEndDate = endDate;
    }
    
    handleBarChartDateSelection(event) {
        // Handle bar chart date selection
        this.showBarChartFilterModal = false;
        const { startDate, endDate } = event.detail;
        this.batchFilterStartDate = startDate;
        this.batchFilterEndDate = endDate; 
    }
    

}