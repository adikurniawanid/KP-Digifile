import React from 'react';
import { Logo, Logout, Profil } from '../../atom';

const Navbarowner = () => {
    return(    
            <nav class="bg-white w-full border-b-2 border-gray-300 px-10 fixed-top">
                <div className="flex justify-between items-center">
                    <div className="flex items-center">
                        <Logo/>
                        <p className="font-semibold text-4xl">Storage</p>
                    </div>
                    <div className="flex items-center">
                        <Profil><Logout/></Profil>
                    </div>
                </div>
            </nav>
    )
}

export default Navbarowner