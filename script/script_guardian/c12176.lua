-- 정령의 단검-엘마
local s,id=GetID()
function s.initial_effect(c)
	-- 장착 마법
	aux.AddEquipProcedure(c)
	-- 2번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- 3번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.anntg)
	e2:SetOperation(s.annop)
	c:RegisterEffect(e2)
	-- 4번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	-- 1번 효과
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_SZONE|LOCATION_GRAVE)
	e0:SetValue(69243953)
	c:RegisterEffect(e0)
end
    -- "가디언 에아토스", "나비의 단검-엘마"의 카드명이 쓰여짐
s.listed_names = {34022290, 69243953}
    -- "가디언"의 테마명이 쓰여짐
s.listed_series = {0x52}
	-- 장착 마법 카드 선언 필터

function s.anntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local code=e:GetHandler():GetCode()
	s.announce_filter={TYPE_EQUIP,OPCODE_ISTYPE,code,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	e:SetLabel(Duel.AnnounceCard(tp,table.unpack(s.announce_filter)))
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP)
end
function s.annop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local an=e:GetLabel()
	if not an then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(an)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) 
	and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():CheckUniqueOnField(tp)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x52)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
	and c:CheckUniqueOnField(tp) and Duel.Equip(tp,c,tc)
	and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,34022290),tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end