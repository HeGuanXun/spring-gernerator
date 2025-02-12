<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="${content.dao.classPackage}.${content.dao.className}">
	<resultMap id="${content.mapper.item.resultMap.value}" type="${content.entity.classPackage}.${content.entity.className}">
		<#if content.entity.primaryKeyAttr??><id column="${content.entity.primaryKeyAttr.columnName}" property="${content.entity.primaryKeyAttr.field}" /></#if>
		<#if content.entity.cantNullAttrs??><#list content.entity.cantNullAttrs as item>
		<result column="${item.columnName}" property="${item.field}" />
		</#list></#if>
		<#if content.entity.otherAttrs??><#list content.entity.otherAttrs as item>
		<result column="${item.columnName}" property="${item.field}" />
		</#list></#if>
	</resultMap>

	<sql id="${content.entity.tableName}_Column">
		<#list content.entity.attrs as item>`${item.columnName}`<#if item?has_next>,</#if></#list>
	</sql>

	<!--获得类名为:${content.entity.className}对应的数据库表的数据总行数 -->
	<select id="${content.dao.item.count.value}" parameterType="${content.basePackage}.utils.Assist" resultType="java.lang.Long">
		select count(*) from ${content.entity.tableName}
		<if test="require!=null">
			<include refid="${content.mapper.item.assist.value}" />
		</if>
		<if test="currentPage!=null and pageSize!=null">
			limit ${content.page.mapperCurrentPage},${content.page.pageSize}
		</if>
	</select>

	<!-- 获得类名为:${content.entity.className}对应数据库中表的数据集合 -->
	<select id="${content.dao.item.select.value}" parameterType="${content.basePackage}.utils.Assist" resultMap="${content.mapper.item.resultMap.value}">
		select * from (
			select
		<choose>
			<when test="resultColumn!=null">${r'${resultColumn}'}</when>
			<otherwise><include refid="${content.entity.tableName}_Column" /></otherwise>
		</choose>
			from ${content.entity.tableName}
		<if test="require!=null"><include refid="${content.mapper.item.assist.value}" /></if>
		<if test="order !=null">${r'${order}'}</if>
		     order by id desc
			) result
		<if test="currentPage!=null and pageSize!=null">
			limit ${content.page.mapperCurrentPage},${content.page.pageSize}
		</if>
	</select>
	<#if content.entity.primaryKeyAttr??>
		<!-- 通过${content.entity.className}的id获得对应数据库中表的数据对象 -->
		<select id="${content.dao.item.selectById.value}" parameterType="${content.entity.primaryKeyAttr.javaType}" resultMap="${content.mapper.item.resultMap.value}">
		select
			<include refid="${content.entity.tableName}_Column" />
		from ${content.entity.tableName}
		where ${content.entity.primaryKeyAttr.columnName} = ${r'#{'}id${r'}'}
		</select>
	</#if>

	<!-- 获得一个${content.entity.className}对象,以参数${content.entity.className}对象中不为空的属性作为条件进行查询 -->
	<select id="${content.dao.item.selectByObjSingle.value}" parameterType="${content.entity.classPackage}.${content.entity.className}" resultMap="${content.mapper.item.resultMap.value}">
		select top 1
		<include refid="${content.entity.tableName}_Column" />
		from ${content.entity.tableName}
		<where>
			<#if content.entity.otherAttrs??><#list content.entity.otherAttrs as item>
			<if test="${item.field} != null"> and ${item.columnName} = ${r'#{'}${item.field}${r'}'}</if>
			</#list></#if>
			<#if content.entity.cantNullAttrs??><#list content.entity.cantNullAttrs as item>
			<if test="${item.field} != null"> and ${item.columnName} = ${r'#{'}${item.field}${r'}'}</if>
			</#list></#if>
			<#if content.entity.primaryKeyAttr??><if test="${content.entity.primaryKeyAttr.field} != null"> and ${content.entity.primaryKeyAttr.columnName} = ${r'#{'}${content.entity.primaryKeyAttr.field}${r'}'} </if></#if>
		</where>
		LIMIT 1
	</select>

	<!-- 获得${content.entity.className}对象,以参数${content.entity.className}对象中不为空的属性作为条件进行查询 -->
	<select id="${content.dao.item.selectByObj.value}" parameterType="${content.entity.classPackage}.${content.entity.className}" resultMap="${content.mapper.item.resultMap.value}">
		select
		<include refid="${content.entity.tableName}_Column" />
		from ${content.entity.tableName}
		<where>
			<#if content.entity.otherAttrs??><#list content.entity.otherAttrs as item>
			<if test="${item.field} != null"> and ${item.columnName} = ${r'#{'}${item.field}${r'}'}</if>
			</#list></#if>
			<#if content.entity.cantNullAttrs??><#list content.entity.cantNullAttrs as item>
			<if test="${item.field} != null"> and ${item.columnName} = ${r'#{'}${item.field}${r'}'}</if>
			</#list></#if>
			<#if content.entity.primaryKeyAttr??><if test="${content.entity.primaryKeyAttr.field} != null"> and ${content.entity.primaryKeyAttr.columnName} = ${r'#{'}${content.entity.primaryKeyAttr.field}${r'}'} </if></#if>
		</where>
	</select>

	<!-- 将${content.entity.className}中属性值不为null的数据,插入到对应数据库的表中 -->
	<insert id="${content.dao.item.insertNotNull.value}" parameterType="${content.entity.classPackage}.${content.entity.className}">
		insert into ${content.entity.tableName}
		<trim prefix="(" suffix=")" suffixOverrides=",">
			<#list content.entity.attrs as item>
			<if test="${item.field} != null">${item.columnName},</if>
			</#list>
		</trim>
		<trim prefix="values (" suffix=")" suffixOverrides=",">
			<#list content.entity.attrs as item>
			<if test="${item.field} != null">${r'#{'}${item.field}${r'}'},</if>
			</#list>
		</trim>
	</insert>

	<!-- 将${content.entity.className}批量插入到对应数据库的表中 -->
	<insert id="${content.dao.item.insertBatch.value}" parameterType="ArrayList">
		insert into ${content.entity.tableName}(<#list content.entity.attrs as item>${item.columnName}<#if item?has_next>,</#if></#list>) values
		<foreach collection="list" item="item" index="index"
				 separator=",">
			(<#list content.entity.attrs as item>${r'#{item.'}${item.field}${r'}'}<#if item?has_next>,</#if></#list>)
		</foreach>
	</insert>

	<#if content.entity.primaryKeyAttr??>
		<!-- 通过${content.entity.className}的id将数据库表中对应的数据删除 -->
		<delete id="${content.dao.item.deleteById.value}" parameterType="${content.entity.primaryKeyAttr.javaType}">
		delete from ${content.entity.tableName}
		where  ${content.entity.primaryKeyAttr.columnName}  =  ${r'#{'}id${r'}'}
		</delete>
	</#if>

	<#if content.entity.primaryKeyAttr??>
		<!-- 通过${content.entity.className}的id将${content.entity.className}中属性值不为null的数据更新到数据库对应的表中 -->
		<update id="${content.dao.item.updateNotNullById.value}" parameterType="${content.entity.classPackage}.${content.entity.className}">
		update ${content.entity.tableName}
			<set>
				<#list content.entity.attrs as item>
					<#if item.field != content.entity.primaryKeyAttr.field>
				<if test="${item.field} != null">${item.columnName} = ${r'#{'}${item.field}${r'}'},</if>
					</#if>
				</#list>
			</set>
		where ${content.entity.primaryKeyAttr.columnName} = ${r'#{'}${content.entity.primaryKeyAttr.field}${r'}'}
		</update>
	</#if>
	<!-- ${content.mapper.item.assist.value}是查询辅助工具类, ${r'${req.require}'}表示列名,${r'#{req.value}'}表示值它是防SQL注入的 -->
	<sql id="${content.mapper.item.assist.value}">
		<where>
			<foreach collection="require" item="req" separator=" ">
				${r'${req.require}'} =
				<if test="req.value != null">
					${r'#{req.value}'}
				</if>
				<if test="req.values != null">
					<foreach collection="req.values" item="value" separator=",">
						${r'#{value}'}
					</foreach>
				</if>
				<if test="req.customRequire !=null">
					<foreach collection="req.customRequire" item="cr" separator=" ">
						${r'${cr.require}'}
						<if test="cr.value != null">
							${r'#{cr.value}'}
						</if>
						<if test="cr.values != null">
							<foreach collection="cr.values" item="value"
									 separator=",">
								${r'#{value}'}
							</foreach>
						</if>
						<if test="cr.suffix != null"> ${r'${cr.suffix}'}</if>
					</foreach>
				</if>
				<if test="req.suffix != null"> ${r'${req.suffix}'}</if>
			</foreach>
		</where>
	</sql>

	<!-- ${content.mapper.item.updateAssist.value}用于更新数据查询辅助工具类,作用${content.mapper.item.assist.value}与一致 -->
	<sql id="${content.mapper.item.updateAssist.value}">
		<where>
			<foreach collection="assist.require" item="req" separator=" ">
				${r'${req.require}'} =
				<if test="req.value != null">
					${r'#{req.value}'}
				</if>
				<if test="req.values != null">
					<foreach collection="req.values" item="value" separator=",">
						${r'#{value}'}
					</foreach>
				</if>
				<if test="req.customRequire !=null">
					<foreach collection="req.customRequire" item="cr" separator=" ">
						${r'${cr.require}'}
						<if test="cr.value != null">
							${r'#{cr.value}'}
						</if>
						<if test="cr.values != null">
							<foreach collection="cr.values" item="value"
									 separator=",">
								${r'#{value}'}
							</foreach>
						</if>
						<if test="cr.suffix != null"> ${r'${cr.suffix}'}</if>
					</foreach>
				</if>
				<if test="req.suffix != null"> ${r'${req.suffix}'}</if>
			</foreach>
		</where>
	</sql>

</mapper>