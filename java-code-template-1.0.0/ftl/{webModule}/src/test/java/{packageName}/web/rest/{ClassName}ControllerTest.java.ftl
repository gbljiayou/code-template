<#include "/abstracted/common.ftl">
<#include "/abstracted/checkFeatureForRest.ftl">
<#--判断如果不需要生成当前文件，则直接跳过-->
<#if !getGenRest(this.metaEntity)>
    <@call this.skipCurrent()/>
</#if>
<@call this.addImport("${this.commonPackage}.util.JsonUtil")/>
<@call this.addImport("${this.packageName}.help.${this.classNameUpper}Helper")/>
<@call this.addImport("${this.packageName}.pojo.dto.${this.classNameUpper}AddDTO")/>
<@call this.addImport("${this.packageName}.pojo.dto.${this.classNameUpper}UpdateDTO")/>
<@call this.addImport("${this.packageName}.pojo.po.${this.classNameUpper}PO")/>
<@call this.addImport("${this.packageName}.web.AbstractWebTest")/>
<@call this.addImport("${this.packageName}.web.constant.WebConst")/>
<@call this.addImport("org.junit.Test")/>
<@call this.addImport("org.springframework.beans.factory.annotation.Autowired")/>
<@call this.addImport("org.springframework.http.MediaType")/>
<@call this.addStaticImport("org.hamcrest.Matchers.is")/>
<@call this.addStaticImport("org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*")/>
<@call this.addStaticImport("org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath")/>
<@call this.addStaticImport("org.springframework.test.web.servlet.result.MockMvcResultMatchers.status")/>
<#--获取保存Example的代码-->
<#assign saveExampleCode=this.getPrintingSaveExample()/>
<#--定义方法区代码-->
<#assign methodCode>
<#if this.entityFeature.save>
    /**
     * 新增【${this.title}】
     */
    @Test
    public void save() throws Exception {
    <#list saveExampleCode as saveExample>
        <#if saveExample?hasNext>
        ${saveExample}
        </#if>
    </#list>
        ${this.classNameUpper}AddDTO addDTO = ${this.className}Helper.get${this.classNameUpper}AddDTO(<@call this.printSaveExampleArg(this.metaEntity)/>);
        restMockMvc.perform(post(WebConst.API_PATH + "/${this.className}")
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(addDTO)))
            .andExpect(status().isCreated());
    }

</#if>
<#if this.entityFeature.update>
    /**
     * 修改【${this.title}】
     */
    @Test
    public void update() throws Exception {
        <#list saveExampleCode as saveExample>
        ${saveExample}
        </#list>
        ${this.classNameUpper}UpdateDTO updateDTO = ${this.className}Helper.get${this.classNameUpper}UpdateDTO(${this.className});
        restMockMvc.perform(put(WebConst.API_PATH + "/${this.className}")
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(updateDTO)))
            .andExpect(status().isOk());
    }

</#if>
<#if this.entityFeature.list>
    /**
    <#if this.pageSign>
     * 分页查询【${this.title}】
    <#else>
     * 列表查询【${this.title}】
    </#if>
     */
    @Test
    public void list() throws Exception {
    <#list saveExampleCode as saveExample>
        ${saveExample}
    </#list>
        restMockMvc.perform(get(WebConst.API_PATH + "/${this.className}"))
            .andExpect(status().isOk())
    <#if this.pageSign>
            .andExpect(jsonPath("$.list.length()").value(is(1)));
    <#else>
            .andExpect(jsonPath("$.length()").value(is(1)));
    </#if>
    }

</#if>
<#if this.titleField??>
    /**
     * 查询【${this.title}】选项列表
     */
    @Test
    public void findOptions() throws Exception {
    <#list saveExampleCode as saveExample>
        ${saveExample}
    </#list>
        restMockMvc.perform(get(WebConst.API_PATH + "/${this.className}/options"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(is(1)));
    }

</#if>
<#if this.entityFeature.show>
    /**
     * 查看【${this.title}】详情
     */
    @Test
    public void show() throws Exception {
    <#list saveExampleCode as saveExample>
        ${saveExample}
    </#list>
        restMockMvc.perform(get(WebConst.API_PATH + "/${this.className}/{${this.id}}",${this.className}.get${this.idUpper}()))
            .andExpect(status().isOk());
    }

</#if>
<#if this.entityFeature.delete>
    /**
     * 删除单个【${this.title}】
     */
    @Test
    public void del() throws Exception {
    <#list saveExampleCode as saveExample>
        ${saveExample}
    </#list>
        restMockMvc.perform(delete(WebConst.API_PATH + "/${this.className}/{${this.id}}",${this.className}.get${this.idUpper}()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").value(is(1)));
    }

</#if>
<#if this.entityFeature.deleteBatch>
    <@call this.addImport("com.google.common.collect.Lists")/>
    /**
     * 批量删除【${this.title}】
     */
    @Test
    public void deleteBatch() throws Exception {
    <#list saveExampleCode as saveExample>
        ${saveExample}
    </#list>
        restMockMvc.perform(delete(WebConst.API_PATH + "/${this.className}")
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(Lists.newArrayList(${this.className}.get${this.idUpper}()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").value(is(1)));
    }

</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign otherPk=otherEntity.pkField>
    <#assign otherCName=otherEntity.className?capFirst>
    <#assign othercName=otherEntity.className?uncapFirst>
    <#assign otherFkId=mtm.getFkAlias(otherEntity.entityId,false)>
    <#--获取保存Example的代码-->
    <#assign saveExampleCode=this.getPrintingSaveExampleForMtm(otherEntity)/>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.addRemove>
        <@call this.addImport("com.google.common.collect.Lists")/>
    /**
     * 添加/移除【${otherEntity.title}】关联
     */
    @Test
    public void addRemove${otherCName}2() throws Exception {
        <#list saveExampleCode as saveExample>
        ${saveExample}
        </#list>
        // 先测试添加【${otherEntity.title}】关联
        restMockMvc.perform(post(WebConst.API_PATH + "/${this.className}/{${this.id}}/${othercName}",
            ${this.className}.get${this.idUpper}())
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(Lists.newArrayList(${othercName}.get${otherPk.jfieldName?capFirst}()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").value(is(1)));
        // 再测试查询【${otherEntity.title}】关联
        restMockMvc.perform(get(WebConst.API_PATH + "/${this.className}/{${this.id}}/${othercName}",
            ${this.className}.get${this.idUpper}()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(is(1)));
        // 最后测试移除【${otherEntity.title}】关联
        restMockMvc.perform(delete(WebConst.API_PATH + "/${this.className}/{${this.id}}/${othercName}",
            ${this.className}.get${this.idUpper}())
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(Lists.newArrayList(${othercName}.get${otherPk.jfieldName?capFirst}()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").value(is(1)));
    }

    </#if>
    <#if entityFeature.set>
        <@call this.addImport("com.google.common.collect.Lists")/>
    /**
     * 设置【${otherEntity.title}】关联
     */
    @Test
    public void set${otherCName}() throws Exception {
        <#list saveExampleCode as saveExample>
        ${saveExample}
        </#list>
        // 先测试设置【${otherEntity.title}】关联
        restMockMvc.perform(put(WebConst.API_PATH + "/${this.className}/{${this.id}}/${othercName}",
            ${this.className}.get${this.idUpper}())
            .contentType(MediaType.APPLICATION_JSON)
            .content(JsonUtil.toJSONString(Lists.newArrayList(${othercName}.get${otherPk.jfieldName?capFirst}()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").value(is(1)));
        // 再测试查询【${otherEntity.title}】关联
        restMockMvc.perform(get(WebConst.API_PATH + "/${this.className}/{${this.id}}/${othercName}",
            ${this.className}.get${this.idUpper}()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(is(1)));
    }

    </#if>
</#list>
</#assign>
<#--开始渲染代码-->
package ${this.packageName}.web.rest;

<@call this.printImport()/>

<@call this.printClassCom("【${this.title}】单元测试")/>
public class ${this.classNameUpper}ControllerTest extends AbstractWebTest {

<@call this.printAutowired()/>


${methodCode}

}
