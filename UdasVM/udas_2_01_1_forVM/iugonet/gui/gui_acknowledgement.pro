;+
; NAME: 
;   gui_acknowledgement, instrument=instrument, $
;                        datatype=datatype, $
;                        site_or_param=site_or_param, $
;                        par_names=par_names
;
; PURPOSE:
;   Show data policy for IUGONET data on GUI
;
; Written by: Y.-M. Tanaka, May 11, 2012 (ytanaka at nipr.ac.jp)
;-

function gui_acknowledgement, instrument=instrument, datatype=datatype, $
              site_or_param=site_or_param, par_names=par_names

if par_names[0] eq '' then return, 'Cancel'

;----- Get !iugonet.data_policy -----;
case instrument of 
  'Automatic_Weather_Station': begin
      case site_or_param of
          'bik': iug_var = !iugonet.data_policy.aws_rish_id
          'ktb': iug_var = !iugonet.data_policy.aws_rish_ktb
          'mnd': iug_var = !iugonet.data_policy.aws_rish_id
          'pon': iug_var = !iugonet.data_policy.aws_rish_id
          'sgk': iug_var = !iugonet.data_policy.aws_rish_sgk
      endcase
    end
  'Boundary_Layer_Radar': begin
      case site_or_param of
          'ktb': iug_var = !iugonet.data_policy.blr_rish_ktb
          'sgk': iug_var = !iugonet.data_policy.blr_rish_sgk
          'srp': iug_var = !iugonet.data_policy.blr_rish_srp
      endcase
    end   
  'EISCAT_radar'               : iug_var = !iugonet.data_policy.eiscat
  'Equatorial_Atmosphere_Radar': iug_var = !iugonet.data_policy.ear
  'geomagnetic_field_index': begin
      case datatype of
        'ASY_index': iug_var = !iugonet.data_policy.gmag_wdc_ae_asy
        'AE_index' : iug_var = !iugonet.data_policy.gmag_wdc_ae_asy
        'Dst_index': iug_var = !iugonet.data_policy.gmag_wdc_dst
      endcase
    end
  'geomagnetic_field_fluxgate': begin
      case datatype of
        'magdas'   : iug_var = !iugonet.data_policy.gmag_magdas
        '210mm#'   : begin
          case site_or_param of 
            'adl': iug_var = !iugonet.data_policy.gmag_mm210_adl
            'bik': iug_var = !iugonet.data_policy.gmag_mm210_bik
            'bsv': iug_var = !iugonet.data_policy.gmag_mm210_bsv
            'can': iug_var = !iugonet.data_policy.gmag_mm210_can
            'cbi': iug_var = !iugonet.data_policy.gmag_mm210_cbi
            'chd': iug_var = !iugonet.data_policy.gmag_mm210_chd
            'dal': iug_var = !iugonet.data_policy.gmag_mm210_dal
            'daw': iug_var = !iugonet.data_policy.gmag_mm210_daw
            'ewa': iug_var = !iugonet.data_policy.gmag_mm210_ewa
            'gua': iug_var = !iugonet.data_policy.gmag_mm210_gua
            'kag': iug_var = !iugonet.data_policy.gmag_mm210_kag
            'kat': iug_var = !iugonet.data_policy.gmag_mm210_kat
            'kot': iug_var = !iugonet.data_policy.gmag_mm210_kot
            'ktb': iug_var = !iugonet.data_policy.gmag_mm210_ktb
            'ktn': iug_var = !iugonet.data_policy.gmag_mm210_ktn
            'lmt': iug_var = !iugonet.data_policy.gmag_mm210_lmt
            'lnp': iug_var = !iugonet.data_policy.gmag_mm210_lnp
            'mcq': iug_var = !iugonet.data_policy.gmag_mm210_mcq
            'mgd': iug_var = !iugonet.data_policy.gmag_mm210_mgd
            'msr': iug_var = !iugonet.data_policy.gmag_mm210_msr
            'mut': iug_var = !iugonet.data_policy.gmag_mm210_mut
            'onw': iug_var = !iugonet.data_policy.gmag_mm210_onw
            'ppi': iug_var = !iugonet.data_policy.gmag_mm210_ppi
            'ptk': iug_var = !iugonet.data_policy.gmag_mm210_ptk
            'ptn': iug_var = !iugonet.data_policy.gmag_mm210_ptn
            'rik': iug_var = !iugonet.data_policy.gmag_mm210_rik
            'tik': iug_var = !iugonet.data_policy.gmag_mm210_tik
            'wep': iug_var = !iugonet.data_policy.gmag_mm210_wep
            'wew': iug_var = !iugonet.data_policy.gmag_mm210_wew
            'wtk': iug_var = !iugonet.data_policy.gmag_mm210_wtk
            'yap': iug_var = !iugonet.data_policy.gmag_mm210_yap
            'ymk': iug_var = !iugonet.data_policy.gmag_mm210_ymk
            'zyk': iug_var = !iugonet.data_policy.gmag_mm210_zyk
          endcase
        endcase
        'WDC_kyoto': iug_var = !iugonet.data_policy.gmag_wdc
        'NIPR_mag#': begin
            case site_or_param of
                'syo': iug_var = !iugonet.data_policy.gmag_nipr_syo
                'aed': iug_var = !iugonet.data_policy.gmag_nipr_ice
                'hus': iug_var = !iugonet.data_policy.gmag_nipr_ice
                'isa': iug_var = !iugonet.data_policy.gmag_nipr_ice
                'tjo': iug_var = !iugonet.data_policy.gmag_nipr_ice
            endcase
          end
      endcase
    end
  'geomagnetic_field_induction': begin
      case datatype of
        'NIPR_mag#': begin
            case site_or_param of
                'syo': iug_var = !iugonet.data_policy.imag_nipr_syo
                'aed': iug_var = !iugonet.data_policy.imag_nipr_ice
                'hus': iug_var = !iugonet.data_policy.imag_nipr_ice
                'isa': iug_var = !iugonet.data_policy.imag_nipr_ice
                'tjo': iug_var = !iugonet.data_policy.imag_nipr_ice
            endcase
          end
        'STEL#': begin
            iug_var = !iugonet.data_policy.imag_stel
          end
      endcase
    end
  'HF_Solar_Jupiter_radio_spectrometer': iug_var = !iugonet.data_policy.hf_tohokuu
  'Iitate_Planetary_Radio_Telescope': iug_var = !iugonet.data_policy.iprt
  'Imaging_Riometer': begin
      case site_or_param of
        'syo': iug_var = !iugonet.data_policy.irio_nipr_syo
        'hus': iug_var = !iugonet.data_policy.irio_nipr_ice
        'tjo': iug_var = !iugonet.data_policy.irio_nipr_ice
      endcase
    end
  'Ionosonde'                     : iug_var = !iugonet.data_policy.ionosonde_rish
  'Lower_Troposphere_Radar'       : iug_var = !iugonet.data_policy.ltr_rish
  'Low_Frequency_radio_transmitter' : iug_var = !iugonet.data_policy.lfrto
  'Medium_Frequency_radar'        : iug_var = !iugonet.data_policy.mf_rish
  'Meteor_Wind_radar'             : iug_var = !iugonet.data_policy.meteor_rish
  'Middle_Upper_atmosphere_radar' : iug_var = !iugonet.data_policy.mu
  'Radiosonde'                    : iug_var = !iugonet.data_policy.radiosonde_rish
  'SuperDARN_radar': begin
      case site_or_param of
        'hok': iug_var = !iugonet.data_policy.sdfit_hok
        'sye': iug_var = !iugonet.data_policy.sdfit_syo
        'sys': iug_var = !iugonet.data_policy.sdfit_syo
      endcase
    end
  'Wind_Profiler_Radar_(LQ-7)'    : begin
      case site_or_param of
        'bik': iug_var = !iugonet.data_policy.wpr_rish_bik
        'mnd': iug_var = !iugonet.data_policy.wpr_rish_mnd
        'pon': iug_var = !iugonet.data_policy.wpr_rish_pon
        'sgk': iug_var = !iugonet.data_policy.wpr_rish_sgk
        endcase
    end
endcase

;----- If iug_var is 0, show data policy. -----;
if iug_var eq 1 then begin
  Answer = 'OK'
endif else begin
  Answer = show_acknowledgement(instrument = instrument, datatype = datatype, $
	par_names = par_names)
  if Answer eq 'OK' then begin 
    iug_var = 1

    ;----- Put !iugonet.data_policy -----;
    case instrument of
      'Automatic_Weather_Station': begin
          case site_or_param of
           'bik': !iugonet.data_policy.aws_rish_id  = iug_var
           'ktb': !iugonet.data_policy.aws_rish_ktb = iug_var
           'mnd': !iugonet.data_policy.aws_rish_id  = iug_var
           'pon': !iugonet.data_policy.aws_rish_id  = iug_var
           'sgk': !iugonet.data_policy.aws_rish_sgk = iug_var
          endcase
        end   
      'Boundary_Layer_Radar': begin
          case site_or_param of
           'ktb': !iugonet.data_policy.blr_rish_ktb = iug_var
           'sgk': !iugonet.data_policy.blr_rish_sgk = iug_var
           'srp': !iugonet.data_policy.blr_rish_srp = iug_var
          endcase
        end   
      'EISCAT_radar'                  : !iugonet.data_policy.eiscat = iug_var
      'Equatorial_Atmosphere_Radar'   : !iugonet.data_policy.ear = iug_var
      'geomagnetic_field_index': begin
          case datatype of
            'ASY_index': !iugonet.data_policy.gmag_wdc_ae_asy = iug_var
            'AE_index' : !iugonet.data_policy.gmag_wdc_ae_asy = iug_var
            'Dst_index': !iugonet.data_policy.gmag_wdc_dst = iug_var
          endcase
        end
      'geomagnetic_field_fluxgate': begin
          case datatype of
            'magdas'   : !iugonet.data_policy.gmag_magdas = iug_var
            '210mm#'   : begin
              case site_or_param of 
                'adl': !iugonet.data_policy.gmag_mm210_adl = iug_var
                'bik': !iugonet.data_policy.gmag_mm210_bik = iug_var
                'bsv': !iugonet.data_policy.gmag_mm210_bsv = iug_var
                'can': !iugonet.data_policy.gmag_mm210_can = iug_var
                'cbi': !iugonet.data_policy.gmag_mm210_cbi = iug_var
                'chd': !iugonet.data_policy.gmag_mm210_chd = iug_var
                'dal': !iugonet.data_policy.gmag_mm210_dal = iug_var
                'daw': !iugonet.data_policy.gmag_mm210_daw = iug_var
                'ewa': !iugonet.data_policy.gmag_mm210_ewa = iug_var
                'gua': !iugonet.data_policy.gmag_mm210_gua = iug_var
                'kag': !iugonet.data_policy.gmag_mm210_kag = iug_var
                'kat': !iugonet.data_policy.gmag_mm210_kat = iug_var
                'kot': !iugonet.data_policy.gmag_mm210_kot = iug_var
                'ktb': !iugonet.data_policy.gmag_mm210_ktb = iug_var
                'ktn': !iugonet.data_policy.gmag_mm210_ktn = iug_var
                'lmt': !iugonet.data_policy.gmag_mm210_lmt = iug_var
                'lnp': !iugonet.data_policy.gmag_mm210_lnp = iug_var
                'mcq': !iugonet.data_policy.gmag_mm210_mcq = iug_var
                'mgd': !iugonet.data_policy.gmag_mm210_mgd = iug_var
                'msr': !iugonet.data_policy.gmag_mm210_msr = iug_var
                'mut': !iugonet.data_policy.gmag_mm210_mut = iug_var
                'onw': !iugonet.data_policy.gmag_mm210_onw = iug_var
                'ppi': !iugonet.data_policy.gmag_mm210_ppi = iug_var
                'ptk': !iugonet.data_policy.gmag_mm210_ptk = iug_var
                'ptn': !iugonet.data_policy.gmag_mm210_ptn = iug_var
                'rik': !iugonet.data_policy.gmag_mm210_rik = iug_var
                'tik': !iugonet.data_policy.gmag_mm210_tik = iug_var
                'wep': !iugonet.data_policy.gmag_mm210_wep = iug_var
                'wew': !iugonet.data_policy.gmag_mm210_wew = iug_var
                'wtk': !iugonet.data_policy.gmag_mm210_wtk = iug_var
                'yap': !iugonet.data_policy.gmag_mm210_yap = iug_var
                'ymk': !iugonet.data_policy.gmag_mm210_ymk = iug_var
                'zyk': !iugonet.data_policy.gmag_mm210_zyk = iug_var
              endcase
            endcase
            'WDC_kyoto': !iugonet.data_policy.gmag_wdc = iug_var
            'NIPR_mag#': begin
                case site_or_param of
                    'syo': !iugonet.data_policy.gmag_nipr_syo = iug_var
                    'aed': !iugonet.data_policy.gmag_nipr_ice = iug_var
                    'hus': !iugonet.data_policy.gmag_nipr_ice = iug_var
                    'isa': !iugonet.data_policy.gmag_nipr_ice = iug_var
                    'tjo': !iugonet.data_policy.gmag_nipr_ice = iug_var
                endcase
              end
          endcase
        end
      'geomagnetic_field_induction': begin
          case datatype of
            'NIPR_mag#': begin
                case site_or_param of
                    'syo': !iugonet.data_policy.imag_nipr_syo = iug_var
                    'aed': !iugonet.data_policy.imag_nipr_ice = iug_var
                    'hus': !iugonet.data_policy.imag_nipr_ice = iug_var
                    'isa': !iugonet.data_policy.imag_nipr_ice = iug_var
                    'tjo': !iugonet.data_policy.imag_nipr_ice = iug_var
                endcase
              end
            'STEL#': begin
                !iugonet.data_policy.imag_stel = iug_var
              end
          endcase
        end
      'HF_Solar_Jupiter_radio_spectrometer': !iugonet.data_policy.hf_tohokuu = iug_var
      'Iitate_Planetary_Radio_Telescope': !iugonet.data_policy.iprt = iug_var
      'Imaging_Riometer': begin
          case site_or_param of
            'syo': !iugonet.data_policy.irio_nipr_syo = iug_var
            'hus': !iugonet.data_policy.irio_nipr_ice = iug_var
            'tjo': !iugonet.data_policy.irio_nipr_ice = iug_var
          endcase
        end
      'Ionosonde'                     : !iugonet.data_policy.ionosonde_rish = iug_var
      'Lower_Troposphere_Radar'       : !iugonet.data_policy.ltr_rish = iug_var
      'Low_Frequency_radio_transmitter' : !iugonet.data_policy.lfrto = iug_var
      'Medium_Frequency_radar'        : !iugonet.data_policy.mf_rish = iug_var
      'Meteor_Wind_radar'             : !iugonet.data_policy.meteor_rish = iug_var
      'Middle_Upper_atmosphere_radar' : !iugonet.data_policy.mu = iug_var
      'Radiosonde'                    : !iugonet.data_policy.radiosonde_rish = iug_var
      'SuperDARN_radar': begin
          case site_or_param of
            'hok': !iugonet.data_policy.sdfit_hok = iug_var
            'sye': !iugonet.data_policy.sdfit_syo = iug_var
            'sys': !iugonet.data_policy.sdfit_syo = iug_var
          endcase
        end
      'Wind_Profiler_Radar_(LQ-7)': begin
          case site_or_param of
             'bik': !iugonet.data_policy.wpr_rish_bik = iug_var
             'mnd': !iugonet.data_policy.wpr_rish_mnd = iug_var
             'pon': !iugonet.data_policy.wpr_rish_pon = iug_var
             'sgk': !iugonet.data_policy.wpr_rish_sgk = iug_var
          endcase
        end
    endcase
  endif
endelse

return, Answer

end
