import React from 'react';
import { Search, Logo, Profil } from '../../atom';

const Navbarowner = () => {
    return(    
            <nav class="container bg-white w-full border-b-2 border-gray-300 px-10">
                <div className="flex justify-between items-center">
                    <div className="flex items-center">
                        <Logo/>
                        <p className="font-semibold text-4xl">Storage</p>
                    </div>
                    <div className="flex items-center">
                        <Profil/>
                    </div>
                </div>
            </nav>
    )
}

export default Navbarowner