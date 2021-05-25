# Julia wrapper over typeGRAMPCparam, which contains all problem-specific parameters
mutable struct CGRAMPCparam
    # Problem size variables
    Nx::typeInt
    Nu::typeInt
    Np::typeInt
    Ng::typeInt
    Nh::typeInt
    NgT::typeInt
    NhT::typeInt
    Nc::typeInt


    x0::Ptr{typeRNum}
    xdes::Ptr{typeRNum}

    u0::Ptr{typeRNum}
    udes::Ptr{typeRNum}
    umax::Ptr{typeRNum}
    umin::Ptr{typeRNum}

    p0::Ptr{typeRNum}
    pmax::Ptr{typeRNum}
    pmin::Ptr{typeRNum}

    Thor::typeRNum
    Tmax::typeRNum
    Tmin::typeRNum

    dt::typeRNum
    t0::typeRNum
end


# Julia wrapper typeGRAMPCopt, which contains all algorithm-related options
mutable struct CGRAMPCopt
    Nhor::typeInt
    MaxGradIter::typeInt
    MaxMultIter::typeInt
    ShiftControl::typeInt

    TimeDiscretization::typeInt

    IntegralCost::typeInt
    TerminalCost::typeInt
    IntegratorCost::typeInt

    # ODE Integrator options
    Integrator::typeInt
    IntegratorRelTol::typeRNum
    IntegratorAbsTol::typeRNum
    IntegratorMinStepSize::typeRNum
    IntegratorMaxSteps::typeInt
    FlagsRodas::Ptr{typeInt} # 8-element vector

    # Line search options
    LineSearchType::typeInt
    LineSearchExpAutoFallback::typeInt
    LineSearchMax::typeRNum
    LineSearchMin::typeRNum
    LineSearchInit::typeRNum
    LineSearchAdaptAbsTol::typeRNum
    LineSearchAdaptFactor::typeRNum
    LineSearchIntervalTol::typeRNum
    LineSearchIntervalFactor::typeRNum

    OptimControl::typeInt
    OptimParam::typeInt
    OptimParamLineSearchFactor::typeRNum
    OptimTime::typeInt
    OptimTimeLineSearchFactor::typeRNum

    ScaleProblem::typeInt
    xScale::Ptr{typeRNum}
    xOffset::Ptr{typeRNum}
    uScale::Ptr{typeRNum}
    uOffset::Ptr{typeRNum}
    pScale::Ptr{typeRNum}
    pOffset::Ptr{typeRNum}

    TScale::typeRNum
    TOffset::typeRNum
    JScale::typeRNum

    cScale::Ptr{typeRNum};

    EqualityConstraints::typeInt
    InequalityConstraints::typeInt
    TerminalEqualityConstraints::typeInt
    TerminalInequalityConstraints::typeInt
    ConstraintsHandling::typeInt

    ConstraintsAbsTol::Ptr{typeRNum};

    MultiplierMax::typeRNum
    MultiplierDampingFactor::typeRNum
    PenaltyMax::typeRNum
    PenaltyMin::typeRNum
    PenaltyIncreaseFactor::typeRNum
    PenaltyDecreaseFactor::typeRNum
    PenaltyIncreaseThreshold::typeRNum
    AugLagUpdateGradientRelTol::typeRNum

    ConvergenceCheck::typeInt
    ConvergenceGradientRelTol::typeRNum
end


# Julia wrapper for typeGRAMPCsol, which contains the (public) solution data
mutable struct CGRAMPCsol
    xnext::Ptr{typeRNum}
    unext::Ptr{typeRNum}
    pnext::Ptr{typeRNum}

    Tnext::typeRNum
    J::Ptr{typeRNum} # A 2-element array
    cfct::typeRNum
    pen::typeRNum

    iter::Ptr{typeInt}

    status::typeInt
end


# Julia wrapper for typeGRAMPCrws, which contains the (private) workspace data
mutable struct CGRAMPCrws
    t::Ptr{typeRNum}
    tls::Ptr{typeRNum}

    x::Ptr{typeRNum}
    adj::Ptr{typeRNum}
    dcdx::Ptr{typeRNum}

    u::Ptr{typeRNum}
    uls::Ptr{typeRNum}
    uprev::Ptr{typeRNum}
    gradu::Ptr{typeRNum}
    graduprev::Ptr{typeRNum}
    dcdu::Ptr{typeRNum}

    p::Ptr{typeRNum}
    pls::Ptr{typeRNum}
    pprev::Ptr{typeRNum}
    gradp::Ptr{typeRNum}
    gradpprev::Ptr{typeRNum}
    dcdp::Ptr{typeRNum}

    T::typeRNum
    Tprev::typeRNum
    gradT::typeRNum
    gradTprev::typeRNum
    dcdt::typeRNum

    mult::Ptr{typeRNum}
    pen::Ptr{typeRNum}
    cfct::Ptr{typeRNum}
    cfctprev::Ptr{typeRNum}
    cfctAbsTol::Ptr{typeRNum}

    lsAdapt::Ptr{typeRNum}
    lsExplicit::Ptr{typeRNum}
    rwsScale::Ptr{typeRNum}

    lrwsGeneral::typeInt
    rwsGeneral::Ptr{typeRNum}

    lworkRodas::typeInt
    liworkRodas::typeInt

    rparRodas::Ptr{typeRNum}
    iparRodas::Ptr{typeInt}
    workRodas::Ptr{typeRNum}
    iworkRodas::Ptr{typeInt}
end


# Julia wrapper for typeGRAMPC, which is the main solver type
mutable struct CGRAMPC
    param::Ptr{GRAMPC.CGRAMPCparam}
    opt::Ptr{GRAMPC.CGRAMPCopt}
    sol::Ptr{GRAMPC.CGRAMPCsol}
    rws::Ptr{GRAMPC.CGRAMPCrws}
    userparam::Ptr{typeUSERPARAM};
end
