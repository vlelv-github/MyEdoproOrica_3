-- 일루전 오브 아이즈
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,location=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
    -- "새크리파이스"의 카드명이 쓰여짐
s.listed_names={64631466}
    -- "새크리파이스"의 테마명이 쓰여짐
s.listed_series={0x110}

function s.ritualfil(c)
	return c:IsCode(64631466)
end
function s.forcedgroup(c,e,tp)
	return (c:IsRace(RACE_SPELLCASTER|RACE_ILLUSION) and c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD))
end

function s.cfilter(c,tp)
	-- 전투 / 효과로 파괴된 것이 통상 소환할 수 없는 자신의 "새크리파이스" 몬스터일 경우
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT))) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(tp) and not c:IsSummonableCard()
		and c:IsSetCard(0x110) and c:IsMonster()

end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
