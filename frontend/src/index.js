import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import {stopReportingRuntimeErrors} from 'react-error-overlay';

if(process.env.NODE_ENV === "development"){
  stopReportingRuntimeErrors();
}

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);

reportWebVitals();
