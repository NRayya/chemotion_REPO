import React, { useState } from 'react';
import { Panel } from 'react-bootstrap';
import { ToggleIndicator } from '../../libHome/RepoCommon';
import { MARegisteredTooltip } from './ma/MAComs';
import { MADataModal, MARequestModal } from './ma/MAModals';

const CompNumber = (xvialCom, data = '') => {
  if (!xvialCom || typeof xvialCom === 'undefined' || !xvialCom.allowed || !xvialCom.hasData || data === '') return null;
  const match = xvialCom.data.find(x => x.x_data.xid === data);
  return match ? <span>:&nbsp;{match.x_short_label}</span> : null;
};

const MAPanel = (_props) => {
  const {
    allowRequest, elementId, isEditable, isLogin, data, saveCallback, xvialCom
  } = _props;
  const [expanded, setExpanded] = useState(true);

  const hasData = !!(data && data !== '');
  if (!isLogin && !hasData) return null;
  if (isLogin && !hasData && !isEditable) return null;
  const information = allowRequest && hasData ? <MARegisteredTooltip /> : null;

  return (
    <>
      <span className="repo-pub-sample-header repo-ma-panel">
        <ToggleIndicator onClick={() => setExpanded(!expanded)} name="Material" indicatorStyle={expanded ? 'down' : 'right'} />
        {information}
        <MADataModal isEditable={isEditable} data={data} elementId={elementId} saveCallback={saveCallback} xvialCom={xvialCom} />
      </span>
      <Panel style={{ border: 'none' }} id="collapsible-panel-ma-panel" expanded={expanded} defaultExpanded={expanded} onToggle={() => { }}>
        <Panel.Collapse>
          <Panel.Body style={{ fontSize: '90%', backgroundColor: '#f5f5f5', padding: '4' }}>
            <b>Sample Registration Number in Molecule Archive</b>{CompNumber(xvialCom, data)} <br />
            <b>Request a sample:</b> <MARequestModal allowRequest={allowRequest} data={data} elementId={elementId} isLogin={isLogin} />
          </Panel.Body>
        </Panel.Collapse>
      </Panel>
    </>
  );
};

export default MAPanel;
