# to make environment, call CPXopenCLPEX
function make_env()
    status = Array(Cint, 1)
    tmp = @cpx_ccall(openCPLEX, Ptr{Void}, (Ptr{Cint},), status)
    if tmp == C_NULL
        error("CPLEX: Error creating environment")
    end
    return(CPXenv(tmp))
end

# to make problem, call CPXcreateprob
function make_problem(env::CPXenv)
    @assert env.ptr != C_NULL 
    status = Array(Cint, 1)
    tmp = @cpx_ccall(createprob, Ptr{Void}, (Ptr{Void}, Ptr{Cint}, Ptr{Uint8}), env.ptr, status, "prob")
    if tmp == C_NULL
        error("CPLEX: Error creating problem, $(tmp)")
    end
    return CPXproblem(env, tmp)
end

function read_file!(prob::CPXproblem, filename)
    ret = @cpx_ccall(readcopyprob, Cint, (Ptr{Void}, Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}), prob.env.ptr, prob.lp, filename, C_NULL)
    if ret != 0
        error("CPLEX: Error reading MPS file")
    end
    prob.nvars = @cpx_ccall(getnumcols, Cint, (Ptr{Void}, Ptr{Void}), prob.env.ptr, prob.lp)
    prob.ncons = @cpx_ccall(getnumrows, Cint, (Ptr{Void}, Ptr{Void}), prob.env.ptr, prob.lp)
end

function set_sense!(prob::CPXproblem, sense)
    if sense == :Min
        status = @cpx_ccall(chgobjsen, Void, (Ptr{Void}, Ptr{Void}, Cint), prob.env.ptr, prob.lp, 1)
    elseif sense == :Max
        status = @cpx_ccall(chgobjsen, Void, (Ptr{Void}, Ptr{Void}, Cint), prob.env.ptr, prob.lp, -1)
    else
        error("Unrecognized objective sense $sense")
    end
    if status != 0
        error("CPLEX: Error changing problem sense")
    end
end

function write_problem(prob::CPXproblem, filename)
    ret = @cpx_ccall(writeprob, Int32, (Ptr{Void}, Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}), prob.env.ptr, prob.lp, filename, C_NULL)
    if ret != 0
        error("CPLEX: Error writing problem data")
    end
end

function free_problem(prob::CPXproblem)
    status = @cpx_ccall(freeprob, Int32, (Ptr{Void}, Ptr{Void}), prob.env.ptr, prob.lp)
    if status != 0
        error("CPLEX: Error freeing problem")
    end
end

function close_CPLEX(env::CPXenv)
    status = @cpx_ccall(closeCPLEX, Int32, (Ptr{Void},), env.ptr)
    if status != 0
        error("CPLEX: Error freeing environment")
    end
end