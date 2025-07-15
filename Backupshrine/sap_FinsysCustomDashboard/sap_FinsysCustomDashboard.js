import { LightningElement, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartJs from '@salesforce/resourceUrl/sap_chartJS';
import chartJsDataLabels from '@salesforce/resourceUrl/sap_chartJSDataLabel';
import resizeObserverPolyfill from '@salesforce/resourceUrl/sap_resizeObserverOfChartJs';
import getTransactionData from '@salesforce/apex/SAP_TransactionChartController.getTransactionData';
import calculateTotalFees from '@salesforce/apex/SAP_TransactionChartController.calculateTotalFees';
import getOpenBatchCount from '@salesforce/apex/SAP_TransactionChartController.getOpenBatchCount';
import getClosedBatchCount from '@salesforce/apex/SAP_TransactionChartController.getClosedBatchCount';
import sap_FinsysCustomDashboard from '@salesforce/resourceUrl/sap_finsysCustomDashboard';
import getBatchData from '@salesforce/apex/SAP_TransactionChartController.getBatchData';
import sap_ViewBatchDashboardFinsys from 'c/sap_ViewBatchDashboardFinsys';

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
    { label: 'All', value: 'All' },
    { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
    { label: 'Board of Accountancy', value: 'Board of Accountancy' },
    { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
    { label: 'Notary Public', value: 'Notary Public' },
    { label: 'Sales', value: 'Sales' },
    { label: 'Trademarks', value: 'Trademarks' }
  ];

  connectedCallback() {
    this.setDefaultDates();
    this.updateTotalFees();
    this.handleFetchOpenBatches();
    this.handleFetchClosedBatches();
  }

  setDefaultDates() {
    const today = new Date();
    const pastDate = new Date();
    pastDate.setDate(today.getDate() - 10);

    const formatDate = (date) => {
      if (isNaN(date.getTime())) {
        console.error('Invalid Date:', date);
        return null;
      }
      let mm = String(date.getMonth() + 1).padStart(2, '0');
      let dd = String(date.getDate()).padStart(2, '0');
      let yyyy = date.getFullYear();
      return `${mm}/${dd}/${yyyy}`;
    };

    this.filterStartDate = formatDate(pastDate);
    this.filterEndDate = formatDate(today);
    this.batchFilterStartDate = formatDate(pastDate);
    this.batchFilterEndDate = formatDate(today);

    this.comulativeStartDate = today.toISOString().split('T')[0];
    this.comulativeEndDate = today.toISOString().split('T')[0];
    this.openBatchStartDate = today.toISOString().split('T')[0];
    this.openBatchEndDate = today.toISOString().split('T')[0];
    this.closedBatchStartDate = today.toISOString().split('T')[0];
    this.closedBatchEndDate = today.toISOString().split('T')[0];
    this.selectedBatchCodeForGraph = 'All';
    this.selectedOpenBatchCode = 'All';
    this.selectedClosedBatchCode = 'All';
  }
  
  parseDateForApex(dateStr) {
    if (!dateStr) return null;
    const [month, day, year] = dateStr.split('/');
    return `${year}-${month}-${day}`;
  }

  @wire(getTransactionData, {
    filterStartDate: '$filterStartDate',
    filterEndDate: '$filterEndDate'
  })
  wiredTransactionData({ error, data }) {
    if (data) {
      this.chartData = data;
      if (this.scriptsLoaded) {
        this.initializeLineChart();
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

  handleOpenBatchCodeChange(event) {
    this.selectedOpenBatchCode = event.target.value;
    this.handleFetchOpenBatches();
  }

  handleClosedBatchCodeChange(event) {
    this.selectedClosedBatchCode = event.target.value;
    this.handleFetchClosedBatches();
  }

  updateTotalFees() {
    if (this.comulativeStartDate && this.comulativeEndDate) {
      calculateTotalFees({
        comulativeStartDate: this.comulativeStartDate,
        comulativeEndDate: this.comulativeEndDate
      })
        .then((result) => {
          this.totalDeposited = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
          }).format(result);
        })
        .catch((error) => {
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
        .then((result) => {
          this.openBatches = result;
        })
        .catch((error) => {
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
        .then((result) => {
          this.closedBatches = result;
        })
        .catch((error) => {
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

    loadScript(this, resizeObserverPolyfill)
      .then(() => {
        return loadScript(this, chartJs);
      })
      .then(() => {
        return loadScript(this, chartJsDataLabels);
      })
      .then(() => {
        if (window.Chart && window.ChartDataLabels) {
          window.Chart.register(window.ChartDataLabels);
          this.scriptsLoaded = true;
          if (this.chartData.length > 0) {
            this.initializeLineChart();
          }
          if (this.batchData.length > 0) {
            this.initializeBarChart();
          }
        }
      })
      .catch((error) => {
        console.error('Error loading scripts:', error);
        this.isChartJsInitialized = false;
      });

    if (!this.cssLoaded) {
      loadStyle(this, sap_FinsysCustomDashboard)
        .then(() => {
          this.cssLoaded = true;
        })
        .catch((error) => {
          console.error('Error loading CSS:', error);
        });
    }
  }

  // REMOVED: The initializeCharts() method has been removed to fix the circular reference

  initializeLineChart() {
    try {
      const lineCanvas = this.template.querySelectorAll('canvas')[0];
      if (!lineCanvas) {
        console.error('Line canvas element not found');
        return;
      }
      
      const lineCtx = lineCanvas.getContext('2d');
      if (!lineCtx) {
        console.error('Could not get 2D context for line canvas');
        return;
      }

      // Safety check for data
      if (!this.chartData || !Array.isArray(this.chartData) || this.chartData.length === 0) {
        console.warn('No chart data available for line chart');
        return;
      }

      const groupedData = this.getGroupedData(this.chartData, this.filterStartDate, this.filterEndDate);
      const timePeriod = this.getTimePeriod(this.filterStartDate, this.filterEndDate);

      const labels = groupedData.map((item) => item.label);
      const amounts = groupedData.map((item) => item.amount);

      const aggregateDetailsByRecordType = (details) => {
        if (!details || !Array.isArray(details)) return {};
        
        const aggregated = {};

        details.forEach((detail) => {
          if (!aggregated[detail.recordTypeName]) {
            aggregated[detail.recordTypeName] = {
              count: 0,
              amount: 0
            };
          }
          aggregated[detail.recordTypeName].count += detail.transactionCount;
          aggregated[detail.recordTypeName].amount += detail.amount;
        });

        return aggregated;
      };

      const lineConfig = {
        type: 'line',
        data: {
          labels: labels,
          datasets: [
            {
              label: 'Transaction Amount',
              data: amounts,
              fill: false,
              borderColor: '#3290ED',
              backgroundColor: 'rgb(75, 192, 192)',
              tension: 0.4,
              pointRadius: 6,
              pointHoverRadius: 8,
              pointBackgroundColor: '#3290ED',
              pointBorderColor: '#3290ED',
              pointBorderWidth: 2,
              borderWidth: 3
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            tooltip: {
              enabled: true,
              mode: 'index',
              callbacks: {
                beforeBody: (context) => {
                  if (!context || !context.length || !this.chartData) {
                    return ['No data available'];
                  }
                  
                  const idx = context[0].dataIndex;
                  // Check if index is within bounds
                  if (idx < 0 || idx >= this.chartData.length) {
                    return ['No transactions for this period'];
                  }
                  
                  const data = this.chartData[idx];
                  if (!data?.details || data.details.length === 0) {
                    return ['No transactions for this period'];
                  }

                  const aggregatedDetails = aggregateDetailsByRecordType(data.details);

                  let tooltip = ['Type     Transaction No.    Transaction Amount', '-----------------------------------------------'];

                  let grandTotalCount = 0;
                  let grandTotalAmount = 0;

                  Object.entries(aggregatedDetails).forEach(([recordType, data]) => {
                    grandTotalCount += data.count;
                    grandTotalAmount += data.amount;

                    const formattedAmount = new Intl.NumberFormat('en-US', {
                      style: 'currency',
                      currency: 'USD',
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2
                    }).format(data.amount);

                    tooltip.push(`${recordType.padEnd(14)}${String(data.count).padEnd(20)}${formattedAmount}`);
                  });

                  const formattedGrandTotal = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                  }).format(grandTotalAmount);

                  tooltip.push(`${'Total'.padEnd(14)}${String(grandTotalCount).padEnd(20)}${formattedGrandTotal}`);

                  return tooltip;
                },
                label: () => ''
              },
              titleFont: {
                size: 14,
                weight: 'bold'
              },
              bodyFont: {
                size: 12,
                family: 'monospace'
              },
              padding: 12,
              backgroundColor: '#032D60',
              titleColor: '#FFFFFF',
              bodyColor: '#FFFFFF',
              borderColor: '#ddd',
              borderWidth: 1
            },
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
              },
              ticks: {
                maxRotation: 0,
                minRotation: 0
              }
            }
          }
        }
      };

      if (this.lineChart) {
        this.lineChart.destroy();
      }
      this.lineChart = new Chart(lineCtx, lineConfig);
    } catch (error) {
      console.error('Error initializing line chart:', error);
    }
  }

  initializeBarChart() {
    try {
      const barCanvas = this.template.querySelectorAll('canvas')[1];
      if (!barCanvas) {
        console.error('Bar canvas element not found');
        return;
      }
      
      const barCtx = barCanvas.getContext('2d');
      if (!barCtx) {
        console.error('Could not get 2D context for bar canvas');
        return;
      }
      
      // Safety check for data
      if (!this.batchData || !Array.isArray(this.batchData) || this.batchData.length === 0) {
        console.warn('No batch data available for bar chart');
        return;
      }

      const timePeriod = this.getTimePeriod(this.batchFilterStartDate, this.batchFilterEndDate);
      const groupedData = this.getGroupedBatchData(this.batchData);
      
      if (!groupedData || !Array.isArray(groupedData) || groupedData.length === 0) {
        console.warn('No grouped data available for bar chart');
        return;
      }

      const uniqueDates = [...new Set(groupedData.map((item) => item.batchDate))];
      uniqueDates.sort((a, b) => {
        if (timePeriod === 'month') {
          const weekA = parseInt(a.split(' ')[1]);
          const weekB = parseInt(b.split(' ')[1]);
          return weekA - weekB;
        } else if (timePeriod === 'year' || timePeriod === 'quarter') {
          const [monthA, yearA] = a.split("'");
          const [monthB, yearB] = b.split("'");
          const months = {
            Jan: 1,
            Feb: 2,
            Mar: 3,
            Apr: 4,
            May: 5,
            Jun: 6,
            Jul: 7,
            Aug: 8,
            Sep: 9,
            Oct: 10,
            Nov: 11,
            Dec: 12
          };
          const yearDiff = parseInt('20' + yearA) - parseInt('20' + yearB);
          return yearDiff !== 0 ? yearDiff : months[monthA] - months[monthB];
        } else {
          return new Date(a) - new Date(b);
        }
      });

      const statuses = ['Open', 'Closed', 'Sealed'];

      const calculateTotalsForDate = (date) => {
        const dateData = groupedData.filter((d) => d.batchDate === date);
        const totals = {
          Open: { count: 0, amount: 0 },
          Closed: { count: 0, amount: 0 },
          Sealed: { count: 0, amount: 0 },
          Total: { count: 0, amount: 0 }
        };

        statuses.forEach((status) => {
          const statusData = dateData.filter((d) => d.status === status);

          if (statusData.length > 0) {
            totals[status].count = statusData[0].count;
            totals[status].amount = statusData.reduce((sum, curr) => sum + curr.totalAmount, 0);

            totals.Total.count += statusData[0].count;
            totals.Total.amount += totals[status].amount;
          }
        });

        return totals;
      };

      const datasets = statuses.map((status) => ({
        label: status,
        data: uniqueDates.map((date) => {
          const matchingData = groupedData.filter((d) => d.batchDate === date && d.status === status);
          return matchingData.reduce((sum, curr) => sum + curr.totalAmount, 0);
        }),
        backgroundColor:
          status === 'Open' ? 'rgba(50, 144, 237, 1)'
          : status === 'Closed' ? 'rgba(119, 181, 242, 1)'
          : 'rgba(153, 102, 255, 0.8)',
        stack: 'Stack 0'
      }));

      const barConfig = {
        type: 'bar',
        data: {
          labels: uniqueDates,
          datasets: datasets
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            tooltip: {
              enabled: true,
              mode: 'index',
              callbacks: {
                beforeBody: (context) => {
                  if (!context || !context.length) {
                    return ['No data available'];
                  }
                  
                  const date = context[0].label;
                  const totals = calculateTotalsForDate(date);

                  let tooltip = ['Type         No.        Amount', '--------------------------------'];

                  Object.entries(totals).forEach(([status, data]) => {
                    if (data.count > 0) {
                      const formattedAmount = data.amount.toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                      });
                      tooltip.push(`${status.padEnd(14)}${String(data.count).padEnd(10)}${formattedAmount}`);
                    }
                  });

                  return tooltip;
                },
                label: () => ''
              },
              titleFont: {
                size: 14,
                weight: 'bold'
              },
              bodyFont: {
                size: 12,
                family: 'monospace'
              },
              padding: 12,
              backgroundColor: '#032D60',
              titleColor: '#FFFFFF',
              bodyColor: '#FFFFFF',
              borderColor: '#ddd',
              borderWidth: 1
            },
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
        }
      };

      if (this.barChart) {
        this.barChart.destroy();
      }
      this.barChart = new Chart(barCtx, barConfig);
    } catch (error) {
      console.error('Error initializing bar chart:', error);
    }
  }

  getGroupedBatchData(data) {
    if (!data || data.length === 0) return [];
    return data;
  }

  handleBarClick(event) {
    try {
      if (!this.barChart) return;
      
      const activeElements = this.barChart.getElementsAtEventForMode(event, 'nearest', { intersect: true });
      if (activeElements.length > 0) {
        const firstPoint = activeElements[0];
        const datasetIndex = firstPoint.datasetIndex;
        const index = firstPoint.index;

        if (!this.barChart.data.datasets[datasetIndex] || 
            !this.barChart.data.labels || 
            this.barChart.data.labels.length === 0) {
          return;
        }

        this.barChart.data.datasets[datasetIndex].backgroundColor = Array(this.barChart.data.labels.length).fill('rgba(75, 192, 192, 0.8)');
        this.barChart.data.datasets[datasetIndex].borderColor = Array(this.barChart.data.labels.length).fill('');
        this.barChart.data.datasets[datasetIndex].borderWidth = Array(this.barChart.data.labels.length).fill(0);

        this.barChart.data.datasets[datasetIndex].backgroundColor[index] = 'rgba(230, 153, 0, 0.5)';
        this.barChart.data.datasets[datasetIndex].borderColor[index] = 'orange';
        this.barChart.data.datasets[datasetIndex].borderWidth[index] = 4;

        this.barChart.update();
      }
    } catch (error) {
      console.error('Error in handleBarClick:', error);
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
    this.showLineChartFilterModal = false;
    const { startDate, endDate } = event.detail;
    this.filterStartDate = startDate;
    this.filterEndDate = endDate;
    // The wired method will handle the chart update
  }

  handleBarChartDateSelection(event) {
    this.showBarChartFilterModal = false;
    const { startDate, endDate } = event.detail;
    this.batchFilterStartDate = startDate;
    this.batchFilterEndDate = endDate;
    // The wired method will handle the chart update
  }

  getTimePeriod(startDate, endDate) {
    if (!startDate || !endDate) return 'month';
    
    try {
      const start = new Date(startDate);
      const end = new Date(endDate);
      
      if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        return 'month';
      }
      
      const diffDays = Math.ceil((end - start) / (1000 * 60 * 60 * 24));

      if (diffDays === 0) {
        return 'today';
      } else if (diffDays <= 7) {
        return 'week';
      } else if (diffDays <= 31) {
        return 'month';
      } else if (diffDays <= 92) {
        return 'quarter';
      } else {
        return 'year';
      }
    } catch (error) {
      console.error('Error in getTimePeriod:', error);
      return 'month';
    }
  }

  getGroupedData(data, startDate, endDate) {
    if (!data || !Array.isArray(data) || data.length === 0) return [];

    try {
      const timePeriod = this.getTimePeriod(startDate, endDate);
      let groupedData = {};

      data.forEach((item) => {
        if (!item || !item.trxnDate) return;
        
        const key = item.trxnDate;

        if (!groupedData[key]) {
          groupedData[key] = {
            label: key,
            amount: 0
          };
        }
        groupedData[key].amount += item.amount || 0;
      });

      let result = Object.values(groupedData);

      if (timePeriod === 'month') {
        result.sort((a, b) => {
          const weekA = parseInt(a.label.split(' ')[1] || '0');
          const weekB = parseInt(b.label.split(' ')[1] || '0');
          return weekA - weekB;
        });
      } else if (timePeriod === 'year' || timePeriod === 'quarter') {
        const monthOrder = {
          Jan: 1,
          Feb: 2,
          Mar: 3,
          Apr: 4,
          May: 5,
          Jun: 6,
          Jul: 7,
          Aug: 8,
          Sep: 9,
          Oct: 10,
          Nov: 11,
          Dec: 12
        };
        result.sort((a, b) => {
          if (!a.label || !b.label) return 0;
          
          const monthA = monthOrder[a.label.split("'")[0]] || 0;
          const monthB = monthOrder[b.label.split("'")[0]] || 0;
          return monthA - monthB;
        });
      } else {
        result.sort((a, b) => {
          if (!a.label || !b.label) return 0;
          return new Date(a.label) - new Date(b.label);
        });
      }

      return result;
    } catch (error) {
      console.error('Error in getGroupedData:', error);
      return [];
    }
  }

  async handleViewActivity() {
    const isviewActivity = true;
    await sap_ViewBatchDashboardFinsys.open({
      size: 'small',
      description: 'view batch from finsys dashboard',
      label: 'open batch',
      isViewActivity: isviewActivity
    });
  }

  async handleViewDepositSummary() {
    const isviewDepositSummary = true;

    await sap_ViewBatchDashboardFinsys.open({
      size: 'small',
      description: 'view batch from finsys dashboard',
      label: 'open batch',
      isViewDepositSummary: isviewDepositSummary
    });
  }
}