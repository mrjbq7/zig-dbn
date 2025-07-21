const std = @import("std");

/// A trading execution venue.
pub const Venue = enum(u16) {
    /// CME Globex
    Glbx = 1,
    /// Nasdaq - All Markets
    Xnas = 2,
    /// Nasdaq OMX BX
    Xbos = 3,
    /// Nasdaq OMX PSX
    Xpsx = 4,
    /// Cboe BZX U.S. Equities Exchange
    Bats = 5,
    /// Cboe BYX U.S. Equities Exchange
    Baty = 6,
    /// Cboe EDGA U.S. Equities Exchange
    Edga = 7,
    /// Cboe EDGX U.S. Equities Exchange
    Edgx = 8,
    /// New York Stock Exchange, Inc.
    Xnys = 9,
    /// NYSE National, Inc.
    Xcis = 10,
    /// NYSE MKT LLC
    Xase = 11,
    /// NYSE Arca
    Arcx = 12,
    /// NYSE Texas, Inc.
    Xchi = 13,
    /// Investors Exchange
    Iexg = 14,
    /// FINRA/Nasdaq TRF Carteret
    Finn = 15,
    /// FINRA/Nasdaq TRF Chicago
    Finc = 16,
    /// FINRA/NYSE TRF
    Finy = 17,
    /// MEMX LLC Equities
    Memx = 18,
    /// MIAX Pearl Equities
    Eprl = 19,
    /// NYSE American Options
    Amxo = 20,
    /// BOX Options
    Xbox = 21,
    /// Cboe Options
    Xcbo = 22,
    /// MIAX Emerald
    Emld = 23,
    /// Cboe EDGX Options
    Edgo = 24,
    /// Nasdaq GEMX
    Gmni = 25,
    /// Nasdaq ISE
    Xisx = 26,
    /// Nasdaq MRX
    Mcry = 27,
    /// MIAX Options
    Xmio = 28,
    /// NYSE Arca Options
    Arco = 29,
    /// Options Price Reporting Authority
    Opra = 30,
    /// MIAX Pearl
    Mprl = 31,
    /// Nasdaq Options
    Xndq = 32,
    /// Nasdaq BX Options
    Xbxo = 33,
    /// Cboe C2 Options
    C2Ox = 34,
    /// Nasdaq PHLX
    Xphl = 35,
    /// Cboe BZX Options
    Bato = 36,
    /// MEMX Options
    Mxop = 37,
    /// ICE Europe Commodities
    Ifeu = 38,
    /// ICE Endex
    Ndex = 39,
    /// Databento US Equities - Consolidated
    Dbeq = 40,
    /// MIAX Sapphire
    Sphr = 41,
    /// Long-Term Stock Exchange, Inc.
    Ltse = 42,
    /// Off-Exchange Transactions - Listed Instruments
    Xoff = 43,
    /// IntelligentCross ASPEN Intelligent Bid/Offer
    Aspn = 44,
    /// IntelligentCross ASPEN Maker/Taker
    Asmt = 45,
    /// IntelligentCross ASPEN Inverted
    Aspi = 46,
    /// Databento US Equities - Consolidated
    Equs = 47,
    /// ICE Futures US
    Ifus = 48,
    /// ICE Europe Financials
    Ifll = 49,
    /// Eurex Exchange
    Xeur = 50,
    /// European Energy Exchange
    Xeee = 51,
    _,
};

/// A source of data.
pub const Dataset = enum(u16) {
    /// CME MDP 3.0 Market Data
    glbx_mdp3 = 1,
    /// Nasdaq TotalView-ITCH
    xnas_itch = 2,
    /// Nasdaq BX TotalView-ITCH
    xbos_itch = 3,
    /// Nasdaq PSX TotalView-ITCH
    xpsx_itch = 4,
    /// Cboe BZX Depth
    bats_pitch = 5,
    /// Cboe BYX Depth
    baty_pitch = 6,
    /// Cboe EDGA Depth
    edga_pitch = 7,
    /// Cboe EDGX Depth
    edgx_pitch = 8,
    /// NYSE Integrated
    xnys_pillar = 9,
    /// NYSE National Integrated
    xcis_pillar = 10,
    /// NYSE American Integrated
    xase_pillar = 11,
    /// NYSE Texas Integrated
    xchi_pillar = 12,
    /// NYSE National BBO
    xcis_bbo = 13,
    /// NYSE National Trades
    xcis_trades = 14,
    /// MEMX Memoir Depth
    memx_memoir = 15,
    /// MIAX Pearl Depth
    eprl_dom = 16,
    /// FINRA/Nasdaq TRF (DEPRECATED)
    finn_nls = 17,
    /// FINRA/NYSE TRF (DEPRECATED)
    finy_trades = 18,
    /// OPRA Binary
    opra_pillar = 19,
    /// Databento US Equities Basic
    dbeq_basic = 20,
    /// NYSE Arca Integrated
    arcx_pillar = 21,
    /// IEX TOPS
    iexg_tops = 22,
    /// Databento US Equities Plus
    equs_plus = 23,
    /// NYSE BBO
    xnys_bbo = 24,
    /// NYSE Trades
    xnys_trades = 25,
    /// Nasdaq QBBO
    xnas_qbbo = 26,
    /// Nasdaq NLS
    xnas_nls = 27,
    /// ICE Europe Commodities iMpact
    ifeu_impact = 28,
    /// ICE Endex iMpact
    ndex_impact = 29,
    /// Databento US Equities (All Feeds)
    equs_all = 30,
    /// Nasdaq Basic (NLS and QBBO)
    xnas_basic = 31,
    /// Databento US Equities Summary
    equs_summary = 32,
    /// NYSE National Trades and BBO
    xcis_trades_bbo = 33,
    /// NYSE Trades and BBO
    xnys_trades_bbo = 34,
    /// Databento US Equities Mini
    equs_mini = 35,
    /// ICE Futures US iMpact
    ifus_impact = 36,
    /// ICE Europe Financials iMpact
    ifll_impact = 37,
    /// Eurex EOBI
    xeur_eobi = 38,
    /// European Energy Exchange EOBI
    xeee_eobi = 39,
    _,
};

pub const Publisher = enum(u16) {
    /// CME Globex MDP 3.0
    glbx_mdp3_glbx = 1,
    /// Nasdaq TotalView-ITCH
    xnas_itch_xnas = 2,
    /// Nasdaq BX TotalView-ITCH
    xbos_itch_xbos = 3,
    /// Nasdaq PSX TotalView-ITCH
    xpsx_itch_xpsx = 4,
    /// Cboe BZX Depth
    bats_pitch_bats = 5,
    /// Cboe BYX Depth
    baty_pitch_baty = 6,
    /// Cboe EDGA Depth
    edga_pitch_edga = 7,
    /// Cboe EDGX Depth
    edgx_pitch_edgx = 8,
    /// NYSE Integrated
    xnys_pillar_xnys = 9,
    /// NYSE National Integrated
    xcis_pillar_xcis = 10,
    /// NYSE American Integrated
    xase_pillar_xase = 11,
    /// NYSE Texas Integrated
    xchi_pillar_xchi = 12,
    /// NYSE National BBO
    xcis_bbo_xcis = 13,
    /// NYSE National Trades
    xcis_trades_xcis = 14,
    /// MEMX Memoir Depth
    memx_memoir_memx = 15,
    /// MIAX Pearl Depth
    eprl_dom_eprl = 16,
    /// FINRA/Nasdaq TRF Carteret
    xnas_nls_finn = 17,
    /// FINRA/Nasdaq TRF Chicago
    xnas_nls_finc = 18,
    /// FINRA/NYSE TRF
    xnys_trades_finy = 19,
    /// OPRA - NYSE American Options
    opra_pillar_amxo = 20,
    /// OPRA - BOX Options
    opra_pillar_xbox = 21,
    /// OPRA - Cboe Options
    opra_pillar_xcbo = 22,
    /// OPRA - MIAX Emerald
    opra_pillar_emld = 23,
    /// OPRA - Cboe EDGX Options
    opra_pillar_edgo = 24,
    /// OPRA - Nasdaq GEMX
    opra_pillar_gmni = 25,
    /// OPRA - Nasdaq ISE
    opra_pillar_xisx = 26,
    /// OPRA - Nasdaq MRX
    opra_pillar_mcry = 27,
    /// OPRA - MIAX Options
    opra_pillar_xmio = 28,
    /// OPRA - NYSE Arca Options
    opra_pillar_arco = 29,
    /// OPRA - Options Price Reporting Authority
    opra_pillar_opra = 30,
    /// OPRA - MIAX Pearl
    opra_pillar_mprl = 31,
    /// OPRA - Nasdaq Options
    opra_pillar_xndq = 32,
    /// OPRA - Nasdaq BX Options
    opra_pillar_xbxo = 33,
    /// OPRA - Cboe C2 Options
    opra_pillar_c2ox = 34,
    /// OPRA - Nasdaq PHLX
    opra_pillar_xphl = 35,
    /// OPRA - Cboe BZX Options
    opra_pillar_bato = 36,
    /// OPRA - MEMX Options
    opra_pillar_mxop = 37,
    /// IEX TOPS
    iexg_tops_iexg = 38,
    /// DBEQ Basic - NYSE Texas
    dbeq_basic_xchi = 39,
    /// DBEQ Basic - NYSE National
    dbeq_basic_xcis = 40,
    /// DBEQ Basic - IEX
    dbeq_basic_iexg = 41,
    /// DBEQ Basic - MIAX Pearl
    dbeq_basic_eprl = 42,
    /// NYSE Arca Integrated
    arcx_pillar_arcx = 43,
    /// NYSE BBO
    xnys_bbo_xnys = 44,
    /// NYSE Trades
    xnys_trades_xnys = 45,
    /// Nasdaq QBBO
    xnas_qbbo_xnas = 46,
    /// Nasdaq Trades
    xnas_nls_xnas = 47,
    /// Databento US Equities Plus - NYSE Texas
    equs_plus_xchi = 48,
    /// Databento US Equities Plus - NYSE National
    equs_plus_xcis = 49,
    /// Databento US Equities Plus - IEX
    equs_plus_iexg = 50,
    /// Databento US Equities Plus - MIAX Pearl
    equs_plus_eprl = 51,
    /// Databento US Equities Plus - Nasdaq
    equs_plus_xnas = 52,
    /// Databento US Equities Plus - NYSE
    equs_plus_xnys = 53,
    /// Databento US Equities Plus - FINRA/Nasdaq TRF Carteret
    equs_plus_finn = 54,
    /// Databento US Equities Plus - FINRA/NYSE TRF
    equs_plus_finy = 55,
    /// Databento US Equities Plus - FINRA/Nasdaq TRF Chicago
    equs_plus_finc = 56,
    /// ICE Europe Commodities
    ifeu_impact_ifeu = 57,
    /// ICE Endex
    ndex_impact_ndex = 58,
    /// Databento US Equities Basic - Consolidated
    dbeq_basic_dbeq = 59,
    /// EQUS Plus - Consolidated
    equs_plus_equs = 60,
    /// OPRA - MIAX Sapphire
    opra_pillar_sphr = 61,
    /// Databento US Equities (All Feeds) - NYSE Texas
    equs_all_xchi = 62,
    /// Databento US Equities (All Feeds) - NYSE National
    equs_all_xcis = 63,
    /// Databento US Equities (All Feeds) - IEX
    equs_all_iexg = 64,
    /// Databento US Equities (All Feeds) - MIAX Pearl
    equs_all_eprl = 65,
    /// Databento US Equities (All Feeds) - Nasdaq
    equs_all_xnas = 66,
    /// Databento US Equities (All Feeds) - NYSE
    equs_all_xnys = 67,
    /// Databento US Equities (All Feeds) - FINRA/Nasdaq TRF Carteret
    equs_all_finn = 68,
    /// Databento US Equities (All Feeds) - FINRA/NYSE TRF
    equs_all_finy = 69,
    /// Databento US Equities (All Feeds) - FINRA/Nasdaq TRF Chicago
    equs_all_finc = 70,
    /// Databento US Equities (All Feeds) - Cboe BZX
    equs_all_bats = 71,
    /// Databento US Equities (All Feeds) - Cboe BYX
    equs_all_baty = 72,
    /// Databento US Equities (All Feeds) - Cboe EDGA
    equs_all_edga = 73,
    /// Databento US Equities (All Feeds) - Cboe EDGX
    equs_all_edgx = 74,
    /// Databento US Equities (All Feeds) - Nasdaq BX
    equs_all_xbos = 75,
    /// Databento US Equities (All Feeds) - Nasdaq PSX
    equs_all_xpsx = 76,
    /// Databento US Equities (All Feeds) - MEMX
    equs_all_memx = 77,
    /// Databento US Equities (All Feeds) - NYSE American
    equs_all_xase = 78,
    /// Databento US Equities (All Feeds) - NYSE Arca
    equs_all_arcx = 79,
    /// Databento US Equities (All Feeds) - Long-Term Stock Exchange
    equs_all_ltse = 80,
    /// Nasdaq Basic - Nasdaq
    xnas_basic_xnas = 81,
    /// Nasdaq Basic - FINRA/Nasdaq TRF Carteret
    xnas_basic_finn = 82,
    /// Nasdaq Basic - FINRA/Nasdaq TRF Chicago
    xnas_basic_finc = 83,
    /// ICE Europe - Off-Market Trades
    ifeu_impact_xoff = 84,
    /// ICE Endex - Off-Market Trades
    ndex_impact_xoff = 85,
    /// Nasdaq NLS - Nasdaq BX
    xnas_nls_xbos = 86,
    /// Nasdaq NLS - Nasdaq PSX
    xnas_nls_xpsx = 87,
    /// Nasdaq Basic - Nasdaq BX
    xnas_basic_xbos = 88,
    /// Nasdaq Basic - Nasdaq PSX
    xnas_basic_xpsx = 89,
    /// Databento Equities Summary
    equs_summary_equs = 90,
    /// NYSE National Trades and BBO
    xcis_trades_bbo_xcis = 91,
    /// NYSE Trades and BBO
    xnys_trades_bbo_xnys = 92,
    /// Nasdaq Basic - Consolidated
    xnas_basic_equs = 93,
    /// Databento US Equities (All Feeds) - Consolidated
    equs_all_equs = 94,
    /// Databento US Equities Mini
    equs_mini_equs = 95,
    /// NYSE Trades - Consolidated
    xnys_trades_equs = 96,
    /// ICE Futures US
    ifus_impact_ifus = 97,
    /// ICE Futures US - Off-Market Trades
    ifus_impact_xoff = 98,
    /// ICE Europe Financials
    ifll_impact_ifll = 99,
    /// ICE Europe Financials - Off-Market Trades
    ifll_impact_xoff = 100,
    /// Eurex EOBI
    xeur_eobi_xeur = 101,
    /// European Energy Exchange EOBI
    xeee_eobi_xeee = 102,
    /// Eurex EOBI - Off-Market Trades
    xeur_eobi_xoff = 103,
    /// European Energy Exchange EOBI - Off-Market Trades
    xeee_eobi_xoff = 104,
};
