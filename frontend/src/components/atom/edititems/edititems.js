import React from 'react';
import { FaEllipsisV } from 'react-icons/fa';

function Edititems(props) {
  const [open, setOpen]=React.useState(false);

    return(
      <>
      <button name="edit" onClick={()=>setOpen(!open)}
      ><FaEllipsisV size={20}/></button>
      {open && props.children}
      </>
      
    )
}

export default Edititems