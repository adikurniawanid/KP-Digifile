import React from 'react';
import Avatar from 'react-avatar';

function Profil(props) {
const [open, setOpen]=React.useState(false);
    return(
        <>
        <button onClick={()=>setOpen(!open)} className="w-12 h-12 rounded-full overflow-hidden items-center">
            <Avatar className="m-auto" size={50} name={sessionStorage.getItem("Fullname")} textSizeRatio={1.75}/>
        </button>
        {open && props.children}
        </>
    )
}

export default Profil