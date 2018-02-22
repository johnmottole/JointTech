import React, { Component } from 'react';
import logo from './kneelogo.PNG';
import './App.css';
import Chart from './components/Chart';

class App extends Component {
  constructor(){
    super();
    this.state = {
      chartData:{}
    }
  }

  componentWillMount(){
    this.getChartData();
  }

  getChartData(){
    // Ajax calls here
    this.setState({
      chartData:{
        labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
        datasets:[
          {
            label:'Steps',
            data:[
              617594,
              181045,
              153060,
              106519,
              105162,
              95072,
              10000
            ],
            backgroundColor:[
              '#d51900',
              '#cc1800',
              '#b31500',
              '#991200',
              '#800f00',
              '#660c00',
              '#4d0900',
              '#330600'
            ]
          }
        ]
      }
    });
  }

  render() {
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="Title" >OrthoInsight Health Dashboard</h1>
        </div>
        <Chart className="Charts" chartData={this.state.chartData} patientName="Patient 555" legendPosition="bottom"/>
      </div>
    );
  }
}

export default App;