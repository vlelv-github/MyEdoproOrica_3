-- 방계난생
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
	-- "방계" 테마명이 쓰여짐
s.listed_series = {0xe3}
	-- "방계윤 비잠"의 카드명이 쓰여짐
s.listed_names = {15610297}



function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xe3),
					extrafil=s.fextra}

	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
    local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
    local b3=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
    if chk==0 then return b1 or b2 or b3 end
    local op=0
    if b1 or b2 or b3 then
        op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
    end
    e:SetLabel(op)
    if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        
    elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,LOCATION_ONFIELD)
        
	elseif op==3 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    end
end

function s.spfilter(c,e,tp)
    return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter(c)
	return c:IsSetCard(0xe3)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        -- 특수 소환 효과
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif op==2 then
        -- 마법/함정 파괴
        local tg=Duel.GetFirstTarget()
        if tg and tg:IsRelateToEffect(e) then
            Duel.Destroy(tg,REASON_EFFECT)
        end
    elseif op==3 then
        -- 융합 소환
		local params={
			fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xe3),
			extrafil=s.fextra}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
        -- 디메리트 적용
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetCondition(s.atkcon)
		e2:SetTarget(s.atktg)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_ATTACK_ANNOUNCE)
		e3:SetOperation(s.checkop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetLabelObject(e2)
		Duel.RegisterEffect(e3,tp)
    end
end


function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end