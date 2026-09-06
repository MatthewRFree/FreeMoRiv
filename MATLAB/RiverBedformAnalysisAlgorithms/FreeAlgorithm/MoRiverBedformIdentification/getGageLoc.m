function gageLocOut = getGageLoc(gageLocIn)
% GETGAGELOC Returns the gage location information.
%   GETGAGELOC takes unformatted gage location string and returns a pre
%   formatted string for the gage locations saved in this repository.
%
%   GAGELOCOUT = GETGAGELOC(GAGELOCIN) takes in a string argument for the
%   gagelocation GAGELOCIN. Certain variations have been identified and set
%   in the switch statement. A formatted string GAGELOCOUT is then set and
%   returned.
%
%   Other Functions Referenced:
%       warning(...)
%
% -- Matthew Free 07/2025 --

%% Arguments
    arguments
        gageLocIn string
    end

%% Get Location Info
    switch gageLocIn
        case 'atchison gage'
            gageLocOut = "Atchison (KS), USGS 06818300";
        case 'booneville gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boonille gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boonvile gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boonville city gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boonville gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boonvlle gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'boovlle gage'
            gageLocOut = "Boonville (MO), USGS 06909000";
        case 'glasgow gage'
            gageLocOut = "Glasgow (MO), USGS 06906500";
        case 'herman gage'
            gageLocOut = "Hermann (MO), USGS 06934500";
        case 'hermann city gage'
            gageLocOut = "Hermann (MO), USGS 06934500";
        case 'hermann gage'
            gageLocOut = "Hermann (MO), USGS 06934500";
        case 'jeff city gage'
            gageLocOut = "Jefferson City (MO), USGS 06910450";
        case 'jefferson city city gage'
            gageLocOut = "Jefferson City (MO), USGS 06910450";
        case 'jefferson city gage'
            gageLocOut = "Jefferson City (MO), USGS 06910450";
        case 'kansas city gage'
            gageLocOut = "Kansas City (MO), USGS 06893000";
        case 'leavenworth gage'
            gageLocOut = "Leavenworth (KS), USGS 06820475";
        case 'napoleon gage'
            gageLocOut = "Napoleon (MO), USGS 06894650";
        case 'rulo gage'
            gageLocOut = "Rulo (NE), USGS 06813500";
        case 'st charles gage'
            gageLocOut = "St. Charles (MO), USGS 06935965";
        case 'st. charles gage'
            gageLocOut = "St. Charles (MO), USGS 06935965";
        case 'st. joe gage'
            gageLocOut = "St. Joseph (MO), USGS 06818000";
        case 'warshington gage'
            gageLocOut = "Washington (MO), USGS 06935450";
        case 'washington gage'
            gageLocOut = "Washington (MO), USGS 06935450";
        case 'washington gage at time of collection'
            gageLocOut = "Washington (MO), USGS 06935450";
        case 'waverly gage'
            gageLocOut = "Waverly (MO), USGS 06895500";
        otherwise
            gageLocOut = "Not Specified";
            warning("Invalid Gage Location")
    end
end