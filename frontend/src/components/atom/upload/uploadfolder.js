import React from 'react';
import { FaCloudUploadAlt} from 'react-icons/fa';

function Uploadfolder(props){
  const [open, setOpen]=React.useState(false);

    return(
    <>
    <button  onClick={()=>setOpen(!open)} className="flex py-2 focus:outline-none"><FaCloudUploadAlt size = {30}/>Upload Folder</button>
    {open && props.children}
    </>
    )
}
export default Uploadfolder